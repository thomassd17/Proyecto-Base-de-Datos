-- =====================================================================
-- 03_vistas.sql : vistas útiles para la dueña de la tienda
-- =====================================================================

-- Detalle completo de cada renglón vendido (une las 6 tablas)
CREATE VIEW V_DETALLE_VENTAS AS
SELECT
    v.id_venta,
    v.fecha_hora,
    c.nombre              AS cliente,
    m.descripcion         AS metodo_pago,
    p.id_producto,
    p.nombre              AS producto,
    p.marca,
    d.cantidad,
    d.precio_unitario,
    d.subtotal,
    ROUND((d.precio_unitario - p.precio_compra) * d.cantidad, 2) AS ganancia
FROM DETALLE_VENTA d
JOIN VENTA          v ON d.id_venta    = v.id_venta
JOIN CLIENTE        c ON v.id_cliente  = c.id_cliente
JOIN METODO_DE_PAGO m ON v.id_metodo   = m.id_metodo
JOIN PRODUCTO       p ON d.id_producto = p.id_producto;

-- Cierre del día: total vendido, efectivo y QR por fecha
CREATE VIEW V_CIERRE_DIARIO AS
SELECT
    DATE(v.fecha_hora)                                                    AS fecha,
    COUNT(*)                                                              AS nro_ventas,
    SUM(v.monto_total)                                                    AS total_vendido,
    SUM(CASE WHEN m.descripcion = 'Efectivo' THEN v.monto_total ELSE 0 END) AS total_efectivo,
    SUM(CASE WHEN m.descripcion = 'QR'       THEN v.monto_total ELSE 0 END) AS total_qr
FROM VENTA v
JOIN METODO_DE_PAGO m ON v.id_metodo = m.id_metodo
GROUP BY DATE(v.fecha_hora);

-- Productos con más salida (unidades vendidas e ingresos)
CREATE VIEW V_PRODUCTOS_MAS_VENDIDOS AS
SELECT
    p.id_producto,
    p.nombre,
    p.marca,
    SUM(d.cantidad) AS unidades_vendidas,
    SUM(d.subtotal) AS ingresos
FROM DETALLE_VENTA d
JOIN PRODUCTO p ON d.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre, p.marca
ORDER BY unidades_vendidas DESC, ingresos DESC;

-- Alerta de reabastecimiento (regla de negocio 3):
--   estante <= mínimo y hay en almacén      -> transferir
--   estante + almacén <= mínimo             -> incluir en lista de compras
CREATE VIEW V_ALERTA_REABASTECIMIENTO AS
SELECT
    id_producto,
    nombre,
    marca,
    stock_estante,
    stock_almacen,
    stock_min,
    CASE
        WHEN stock_estante + stock_almacen <= stock_min THEN 'COMPRAR AL MAYOR'
        ELSE 'TRANSFERIR DEL ALMACEN AL ESTANTE'
    END AS accion
FROM PRODUCTO
WHERE stock_estante <= stock_min;
