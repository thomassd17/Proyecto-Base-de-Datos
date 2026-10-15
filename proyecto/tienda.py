"""
Tienda "Natalia" — INF312 Base de Datos I (Hito Unidad IV)

Uso:  python3 tienda.py

1. Crea la base de datos desde cero ejecutando sql/01..03 (BD vacía).
2. Expone funciones de acceso con consultas PARAMETRIZADAS (sin SQL injection)
   y TRANSACCIONES (todo o nada) para registrar ventas.
3. Verifica los resultados clave y muestra el cierre del día.
"""
import os
import sqlite3
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
SQL_DIR = os.path.join(AQUI, "sql")
SCRIPTS = ["01_ddl.sql", "02_datos.sql", "03_vistas.sql"]


# ----------------------------------------------------------------------
# Conexión y creación de la BD
# ----------------------------------------------------------------------
def conectar(ruta=":memory:"):
    # isolation_level=None: las transacciones se controlan a mano (BEGIN/COMMIT)
    conn = sqlite3.connect(ruta, isolation_level=None)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def crear_bd(conn):
    """Ejecuta los scripts DDL, datos y vistas en orden sobre una BD vacía."""
    for nombre in SCRIPTS:
        with open(os.path.join(SQL_DIR, nombre), encoding="utf-8") as f:
            conn.executescript(f.read())


# ----------------------------------------------------------------------
# Operaciones (siempre con parámetros ?, nunca concatenando texto)
# ----------------------------------------------------------------------
def siguiente_id(conn, tabla, columna, prefijo, ancho):
    # tabla/columna son constantes internas del programa, nunca datos del usuario
    fila = conn.execute(
        f"SELECT COALESCE(MAX(CAST(SUBSTR({columna}, ?) AS INTEGER)), 0) + 1 AS n FROM {tabla}",
        (len(prefijo) + 1,),
    ).fetchone()
    return f"{prefijo}{fila['n']:0{ancho}d}"


def registrar_venta(conn, id_cliente, id_metodo, items, fecha_hora=None):
    """
    Registra una venta completa en UNA transacción.
    items: lista de (id_producto, cantidad).
    Si algo falla (stock insuficiente, cliente inexistente...) se hace ROLLBACK
    y no queda nada a medias.
    """
    conn.execute("BEGIN IMMEDIATE")
    try:
        id_venta = siguiente_id(conn, "VENTA", "id_venta", "V", 3)
        if fecha_hora is None:
            conn.execute(
                "INSERT INTO VENTA (id_venta, id_cliente, id_metodo) VALUES (?, ?, ?)",
                (id_venta, id_cliente, id_metodo),
            )
        else:
            conn.execute(
                "INSERT INTO VENTA (id_venta, id_cliente, id_metodo, fecha_hora) VALUES (?, ?, ?, ?)",
                (id_venta, id_cliente, id_metodo, fecha_hora),
            )
        for id_producto, cantidad in items:
            fila = conn.execute(
                "SELECT precio_venta FROM PRODUCTO WHERE id_producto = ?", (id_producto,)
            ).fetchone()
            if fila is None:
                raise ValueError(f"Producto inexistente: {id_producto}")
            id_detalle = siguiente_id(conn, "DETALLE_VENTA", "id_detalle", "D", 2)
            conn.execute(
                "INSERT INTO DETALLE_VENTA (id_detalle, id_venta, id_producto, cantidad, precio_unitario)"
                " VALUES (?, ?, ?, ?, ?)",
                (id_detalle, id_venta, id_producto, cantidad, fila["precio_venta"]),
            )
        conn.execute("COMMIT")
        return id_venta
    except Exception:
        conn.execute("ROLLBACK")
        raise


def buscar_clientes(conn, texto):
    """Búsqueda por nombre con LIKE parametrizado (el texto nunca se concatena al SQL)."""
    return conn.execute(
        "SELECT id_cliente, nombre, telefono FROM CLIENTE WHERE nombre LIKE ? ORDER BY nombre",
        (f"%{texto}%",),
    ).fetchall()


def cierre_del_dia(conn, fecha):
    return conn.execute("SELECT * FROM V_CIERRE_DIARIO WHERE fecha = ?", (fecha,)).fetchone()


# ----------------------------------------------------------------------
# Verificación del hito
# ----------------------------------------------------------------------
def verificar(conn):
    ok = True

    def chequear(descripcion, condicion):
        nonlocal ok
        print(f"  [{'OK' if condicion else 'FALLA'}] {descripcion}")
        ok = ok and condicion

    print("1) Integridad de la base de datos")
    chequear("integrity_check = ok", conn.execute("PRAGMA integrity_check").fetchone()[0] == "ok")
    chequear("sin violaciones de claves foráneas", conn.execute("PRAGMA foreign_key_check").fetchall() == [])

    print("2) Stock final = tablas de normalización (triggers de descuento)")
    esperado = {"P10": 20, "P20": 50, "P30": 30, "P40": 15, "P50": 4, "P60": 3}
    real = {r["id_producto"]: r["stock_estante"]
            for r in conn.execute("SELECT id_producto, stock_estante FROM PRODUCTO")}
    chequear(f"stock en estante {real}", real == esperado)

    print("3) MONTO_TOTAL derivado = suma de subtotales")
    montos = {r["id_venta"]: r["monto_total"] for r in conn.execute("SELECT id_venta, monto_total FROM VENTA")}
    chequear(f"montos {montos}", montos == {"V001": 40.0, "V002": 3.0, "V003": 37.5, "V004": 28.0, "V005": 15.0})

    print("4) Cierre del día 2026-04-10 (vista V_CIERRE_DIARIO)")
    c = cierre_del_dia(conn, "2026-04-10")
    chequear(
        f"ventas={c['nro_ventas']} total={c['total_vendido']} efectivo={c['total_efectivo']} qr={c['total_qr']}",
        (c["nro_ventas"], c["total_vendido"], c["total_efectivo"], c["total_qr"]) == (4, 108.5, 77.5, 31.0),
    )

    print("5) Alerta de reabastecimiento")
    alertas = {r["id_producto"]: r["accion"] for r in conn.execute("SELECT * FROM V_ALERTA_REABASTECIMIENTO")}
    chequear(f"{alertas}", alertas == {"P50": "COMPRAR AL MAYOR", "P60": "TRANSFERIR DEL ALMACEN AL ESTANTE"})

    print("6) Transacción: venta válida desde Python")
    id_v = registrar_venta(conn, "CLI01", "M01", [("P20", 3), ("P40", 1)], "2026-04-12 10:00:00")
    m = conn.execute("SELECT monto_total FROM VENTA WHERE id_venta = ?", (id_v,)).fetchone()[0]
    chequear(f"{id_v} registrada, monto = {m} (3 x 2.00 + 1 x 2.50 = 8.50)", m == 8.5)

    print("7) Transacción: venta con stock insuficiente hace ROLLBACK completo")
    antes = conn.execute("SELECT COUNT(*) FROM VENTA").fetchone()[0]
    stock_antes = conn.execute("SELECT stock_estante FROM PRODUCTO WHERE id_producto='P10'").fetchone()[0]
    try:
        registrar_venta(conn, "CLI01", "M01", [("P10", 1), ("P50", 999)])
        rechazada = False
    except sqlite3.IntegrityError as e:
        rechazada = "Stock insuficiente" in str(e)
    despues = conn.execute("SELECT COUNT(*) FROM VENTA").fetchone()[0]
    stock_despues = conn.execute("SELECT stock_estante FROM PRODUCTO WHERE id_producto='P10'").fetchone()[0]
    chequear("venta rechazada por stock insuficiente", rechazada)
    chequear("no quedó venta a medias y P10 conserva su stock", antes == despues and stock_antes == stock_despues)

    print("8) Seguridad: intento de SQL injection tratado como texto")
    chequear("buscar_clientes(\"' OR '1'='1\") devuelve 0 filas",
             len(buscar_clientes(conn, "' OR '1'='1")) == 0)
    buscar_clientes(conn, "x'; DROP TABLE CLIENTE; --")
    chequear("la tabla CLIENTE sigue existiendo",
             conn.execute("SELECT COUNT(*) FROM CLIENTE").fetchone()[0] == 3)

    print("9) Restricciones")
    for descripcion, sql in [
        ("cantidad <= 0 rechazada", "INSERT INTO DETALLE_VENTA (id_detalle,id_venta,id_producto,cantidad,precio_unitario) VALUES ('X1','V001','P30',0,3)"),
        ("producto repetido en la misma venta rechazado (UNIQUE)", "INSERT INTO DETALLE_VENTA (id_detalle,id_venta,id_producto,cantidad,precio_unitario) VALUES ('X2','V001','P10',1,15)"),
        ("cliente inexistente rechazado (FK)", "INSERT INTO VENTA (id_venta,id_cliente,id_metodo) VALUES ('X3','NO_EXISTE','M01')"),
        ("editar un detalle rechazado", "UPDATE DETALLE_VENTA SET cantidad = 9 WHERE id_detalle = 'D01'"),
    ]:
        try:
            conn.execute(sql)
            chequear(descripcion, False)
            conn.execute("ROLLBACK") if conn.in_transaction else None
        except sqlite3.IntegrityError:
            chequear(descripcion, True)

    return ok


def mostrar(conn, titulo, sql, params=()):
    print(f"\n{titulo}")
    filas = conn.execute(sql, params).fetchall()
    if not filas:
        print("  (sin resultados)")
        return
    cols = filas[0].keys()
    print("  " + " | ".join(cols))
    for f in filas:
        print("  " + " | ".join(str(f[c]) for c in cols))


if __name__ == "__main__":
    ruta = os.path.join(AQUI, "tienda.db")
    if os.path.exists(ruta):
        os.remove(ruta)  # BD vacía para probar el script de inicio a fin
    conn = conectar(ruta)
    crear_bd(conn)
    print("Base de datos creada desde cero: tienda.db\n")
    # Se muestran primero los reportes (con los datos de prueba originales)
    mostrar(conn, "Cierre del día 2026-04-10:", "SELECT * FROM V_CIERRE_DIARIO WHERE fecha = ?", ("2026-04-10",))
    mostrar(conn, "Productos con más salida:", "SELECT * FROM V_PRODUCTOS_MAS_VENDIDOS LIMIT 5")
    mostrar(conn, "Lista de reabastecimiento:", "SELECT * FROM V_ALERTA_REABASTECIMIENTO ORDER BY nombre")

    print("\n--- Verificaciones (algunas registran ventas de prueba) ---\n")
    todo_ok = verificar(conn)

    print("\nRESULTADO:", "TODAS LAS VERIFICACIONES PASARON" if todo_ok else "HAY VERIFICACIONES QUE FALLARON")
    conn.close()
    sys.exit(0 if todo_ok else 1)
