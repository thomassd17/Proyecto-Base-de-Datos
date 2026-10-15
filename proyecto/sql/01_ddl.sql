-- =====================================================================
-- Tienda "Natalia" — Sistema de Inventario y Ventas
-- INF312 Base de Datos I — Hito Unidad IV
-- 01_ddl.sql : estructura (tablas, índices y triggers)
-- Motor: SQLite 3.31+ (usa columnas generadas)
-- Se puede ejecutar de inicio a fin sobre una base de datos vacía.
-- =====================================================================

PRAGMA foreign_keys = ON;

-- Limpieza para poder re-ejecutar el script (orden inverso a las dependencias)
DROP VIEW  IF EXISTS V_PRODUCTOS_MAS_VENDIDOS;
DROP VIEW  IF EXISTS V_ALERTA_REABASTECIMIENTO;
DROP VIEW  IF EXISTS V_CIERRE_DIARIO;
DROP VIEW  IF EXISTS V_DETALLE_VENTAS;
DROP TABLE IF EXISTS DETALLE_VENTA;
DROP TABLE IF EXISTS VENTA;
DROP TABLE IF EXISTS PRODUCTO;
DROP TABLE IF EXISTS ALMACEN;
DROP TABLE IF EXISTS METODO_DE_PAGO;
DROP TABLE IF EXISTS CLIENTE;

-- ---------------------------------------------------------------------
-- TABLAS
-- ---------------------------------------------------------------------

CREATE TABLE CLIENTE (
    id_cliente  TEXT         PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    telefono    VARCHAR(20)
);

CREATE TABLE METODO_DE_PAGO (
    id_metodo    TEXT        PRIMARY KEY,
    descripcion  VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE ALMACEN (
    id_almacen      TEXT         PRIMARY KEY,
    nombre_almacen  VARCHAR(80)  NOT NULL,
    ubicacion       VARCHAR(120)
);

CREATE TABLE PRODUCTO (
    id_producto    TEXT          PRIMARY KEY,
    id_almacen     TEXT          NOT NULL,
    nombre         VARCHAR(100)  NOT NULL,
    marca          VARCHAR(60),
    categoria      VARCHAR(60),
    precio_compra  DECIMAL(10,2) NOT NULL CHECK (precio_compra > 0),
    precio_venta   DECIMAL(10,2) NOT NULL CHECK (precio_venta  > 0),
    stock_estante  INTEGER       NOT NULL DEFAULT 0 CHECK (stock_estante >= 0),
    stock_almacen  INTEGER       NOT NULL DEFAULT 0 CHECK (stock_almacen >= 0),
    stock_min      INTEGER       NOT NULL DEFAULT 0 CHECK (stock_min     >= 0),
    FOREIGN KEY (id_almacen) REFERENCES ALMACEN(id_almacen)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE VENTA (
    id_venta     TEXT          PRIMARY KEY,
    id_cliente   TEXT          NOT NULL,
    id_metodo    TEXT          NOT NULL,
    fecha_hora   TEXT          NOT NULL DEFAULT (datetime('now', 'localtime')),
    -- Derivado: lo mantienen los triggers como suma de los subtotales
    monto_total  DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (monto_total >= 0),
    FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (id_metodo)  REFERENCES METODO_DE_PAGO(id_metodo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE DETALLE_VENTA (
    id_detalle       TEXT          PRIMARY KEY,
    id_venta         TEXT          NOT NULL,
    id_producto      TEXT          NOT NULL,
    cantidad         INTEGER       NOT NULL CHECK (cantidad > 0),
    -- Precio "congelado" al momento de la venta (no cambia si PRODUCTO cambia)
    precio_unitario  DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    -- Derivado: siempre consistente porque lo calcula el propio motor
    subtotal         DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    UNIQUE (id_venta, id_producto),
    FOREIGN KEY (id_venta)    REFERENCES VENTA(id_venta)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ---------------------------------------------------------------------
-- ÍNDICES (FK y columnas usadas en filtros frecuentes)
-- UNIQUE (id_venta, id_producto) ya indexa id_venta en DETALLE_VENTA.
-- ---------------------------------------------------------------------

CREATE INDEX idx_producto_almacen    ON PRODUCTO(id_almacen);
CREATE INDEX idx_producto_nombre     ON PRODUCTO(nombre);
CREATE INDEX idx_venta_cliente       ON VENTA(id_cliente);
CREATE INDEX idx_venta_metodo        ON VENTA(id_metodo);
CREATE INDEX idx_venta_fecha         ON VENTA(fecha_hora);
CREATE INDEX idx_detalle_producto    ON DETALLE_VENTA(id_producto);

-- ---------------------------------------------------------------------
-- TRIGGERS (reglas de negocio)
-- ---------------------------------------------------------------------

-- Regla 1: validar que la cantidad no supere el STOCK_ESTANTE
CREATE TRIGGER trg_detalle_valida_stock
BEFORE INSERT ON DETALLE_VENTA
BEGIN
    SELECT RAISE(ABORT, 'Stock insuficiente en estante')
    WHERE (SELECT stock_estante FROM PRODUCTO WHERE id_producto = NEW.id_producto) < NEW.cantidad;
END;

-- Regla 2: descontar automáticamente el STOCK_ESTANTE
CREATE TRIGGER trg_detalle_descuenta_stock
AFTER INSERT ON DETALLE_VENTA
BEGIN
    UPDATE PRODUCTO
    SET stock_estante = stock_estante - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;

-- Si se elimina un renglón (devolución/anulación), el stock vuelve al estante
CREATE TRIGGER trg_detalle_restituye_stock
AFTER DELETE ON DETALLE_VENTA
BEGIN
    UPDATE PRODUCTO
    SET stock_estante = stock_estante + OLD.cantidad
    WHERE id_producto = OLD.id_producto;
END;

-- Un renglón no se edita: se elimina y se registra de nuevo
-- (así el stock y el monto nunca quedan inconsistentes)
CREATE TRIGGER trg_detalle_no_editable
BEFORE UPDATE OF cantidad, id_producto, precio_unitario ON DETALLE_VENTA
BEGIN
    SELECT RAISE(ABORT, 'Un detalle no se modifica: elimínelo y regístrelo de nuevo');
END;

-- MONTO_TOTAL (derivado) = suma de subtotales de la venta
CREATE TRIGGER trg_monto_total_insert
AFTER INSERT ON DETALLE_VENTA
BEGIN
    UPDATE VENTA
    SET monto_total = (SELECT COALESCE(SUM(subtotal), 0)
                       FROM DETALLE_VENTA WHERE id_venta = NEW.id_venta)
    WHERE id_venta = NEW.id_venta;
END;

CREATE TRIGGER trg_monto_total_delete
AFTER DELETE ON DETALLE_VENTA
BEGIN
    UPDATE VENTA
    SET monto_total = (SELECT COALESCE(SUM(subtotal), 0)
                       FROM DETALLE_VENTA WHERE id_venta = OLD.id_venta)
    WHERE id_venta = OLD.id_venta;
END;
