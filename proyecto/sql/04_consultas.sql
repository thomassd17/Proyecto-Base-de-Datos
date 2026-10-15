-- =====================================================================
-- 04_consultas.sql : consultas requeridas (con el resultado esperado)
-- Los valores esperados corresponden a los datos de 02_datos.sql
-- =====================================================================

-- C1. Cierre del día 2026-04-10: total vendido, efectivo y QR
--     Esperado: 4 ventas | total 108.50 | efectivo 77.50 | QR 31.00
SELECT * FROM V_CIERRE_DIARIO WHERE fecha = '2026-04-10';

-- C2. Cobrado por método de pago en todo el período
--     Esperado: Efectivo 92.50 (V001+V003+V005) | QR 31.00 (V002+V004)
SELECT m.descripcion AS metodo, COUNT(*) AS ventas, SUM(v.monto_total) AS total
FROM VENTA v
JOIN METODO_DE_PAGO m ON v.id_metodo = m.id_metodo
GROUP BY m.descripcion
ORDER BY total DESC;

-- C3. Productos con más salida (top 5)
--     Esperado: Bolígrafo 15 u., Cuaderno 4 u., Regla 3 u., luego los de 2 u.
SELECT * FROM V_PRODUCTOS_MAS_VENDIDOS LIMIT 5;

-- C4. Lista de reabastecimiento
--     Esperado: P50 Marcador -> COMPRAR AL MAYOR | P60 Tijera -> TRANSFERIR
SELECT * FROM V_ALERTA_REABASTECIMIENTO ORDER BY nombre;

-- C5. Historial de compras por cliente (LEFT JOIN: incluye clientes sin ventas)
SELECT c.nombre,
       COUNT(v.id_venta)             AS compras,
       COALESCE(SUM(v.monto_total), 0) AS total_gastado
FROM CLIENTE c
LEFT JOIN VENTA v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre
ORDER BY total_gastado DESC;

-- C6. Ranking de clientes por gasto (función de ventana)
SELECT nombre, total_gastado,
       RANK() OVER (ORDER BY total_gastado DESC) AS puesto
FROM (
    SELECT c.nombre, COALESCE(SUM(v.monto_total), 0) AS total_gastado
    FROM CLIENTE c
    LEFT JOIN VENTA v ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nombre
);

-- C7. Ventas por día con acumulado (CTE + función de ventana)
WITH diario AS (
    SELECT DATE(fecha_hora) AS fecha, SUM(monto_total) AS total
    FROM VENTA
    GROUP BY DATE(fecha_hora)
)
SELECT fecha, total,
       SUM(total) OVER (ORDER BY fecha) AS acumulado
FROM diario;

-- C8. Ganancia por producto (precio vendido - precio de compra)
SELECT producto,
       SUM(cantidad) AS unidades,
       SUM(ganancia) AS ganancia_total
FROM V_DETALLE_VENTAS
GROUP BY id_producto, producto
ORDER BY ganancia_total DESC;

-- C9. Productos que nunca se vendieron (subconsulta con NOT EXISTS)
SELECT nombre FROM PRODUCTO p
WHERE NOT EXISTS (SELECT 1 FROM DETALLE_VENTA d WHERE d.id_producto = p.id_producto);

-- C10. Verificar que el índice se usa (plan de ejecución)
EXPLAIN QUERY PLAN
SELECT * FROM VENTA WHERE fecha_hora >= '2026-04-10 00:00:00';
