-- =====================================================================
-- 06_transacciones.sql : ejemplos de transacciones (versión MySQL)
-- Ejecutar DESPUÉS de 03_datos.sql. NO forma parte del script completo
-- porque la segunda parte provoca un error a propósito.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Venta válida: todo o nada, se confirma con COMMIT
-- ---------------------------------------------------------------------
START TRANSACTION;

INSERT INTO VENTA (id_venta, id_cliente, id_metodo, fecha_hora)
VALUES ('V006', 'CLI01', 'M01', '2026-04-12 10:00:00');

INSERT INTO DETALLE_VENTA (id_detalle, id_venta, id_producto, cantidad, precio_unitario) VALUES
    ('D10', 'V006', 'P20', 3, 2.00),    -- 6.00
    ('D11', 'V006', 'P40', 1, 2.50);    -- 2.50

COMMIT;

-- Esperado: monto_total = 8.50 | Bolígrafo 47 en estante | Regla 14 en estante
SELECT id_venta, monto_total FROM VENTA WHERE id_venta = 'V006';
SELECT id_producto, stock_estante FROM PRODUCTO WHERE id_producto IN ('P20', 'P40');

-- ---------------------------------------------------------------------
-- 2) Venta con stock insuficiente: se deshace TODO con ROLLBACK
--    (el último INSERT da el error "Stock insuficiente en estante";
--     es el resultado esperado de esta prueba)
-- ---------------------------------------------------------------------
START TRANSACTION;

INSERT INTO VENTA (id_venta, id_cliente, id_metodo, fecha_hora)
VALUES ('V007', 'CLI02', 'M02', '2026-04-12 11:00:00');

INSERT INTO DETALLE_VENTA (id_detalle, id_venta, id_producto, cantidad, precio_unitario)
VALUES ('D12', 'V007', 'P10', 1, 15.00);            -- este sí entra

INSERT INTO DETALLE_VENTA (id_detalle, id_venta, id_producto, cantidad, precio_unitario)
VALUES ('D13', 'V007', 'P50', 999, 4.00);           -- ERROR: stock insuficiente

ROLLBACK;

-- Esperado: 0 filas de V007 y P10 conserva su stock (20)
SELECT COUNT(*) AS filas_v007 FROM VENTA WHERE id_venta = 'V007';
SELECT id_producto, stock_estante FROM PRODUCTO WHERE id_producto = 'P10';
