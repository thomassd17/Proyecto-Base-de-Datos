-- =====================================================================
-- 02_datos.sql : datos de prueba coherentes con las tablas de 3FN
-- Las ventas se insertan con sus detalles, por lo que los triggers
-- descuentan el stock y calculan MONTO_TOTAL automáticamente.
-- =====================================================================

PRAGMA foreign_keys = ON;

INSERT INTO METODO_DE_PAGO (id_metodo, descripcion) VALUES
    ('M01', 'Efectivo'),
    ('M02', 'QR');

INSERT INTO CLIENTE (id_cliente, nombre, telefono) VALUES
    ('CLI00', 'CLIENTE MOSTRADOR', NULL),   -- ventas sin datos del cliente
    ('CLI01', 'Juan Pérez',  '70012345'),
    ('CLI02', 'María Añez',  '71123456');

INSERT INTO ALMACEN (id_almacen, nombre_almacen, ubicacion) VALUES
    ('A01', 'Depósito principal', 'Tienda Central (Planta Baja)');

-- Stock INICIAL (antes de las ventas de prueba). Al terminar las ventas
-- quedan los valores de las tablas de normalización:
--   P10: 24 - 4 = 20 | P20: 65 - 15 = 50 | P30: 32 - 2 = 30
--   P40: 18 - 3 = 15 | P50:  6 -  2 =  4 | P60:  5 -  2 =  3
INSERT INTO PRODUCTO
    (id_producto, id_almacen, nombre, marca, categoria,
     precio_compra, precio_venta, stock_estante, stock_almacen, stock_min) VALUES
    ('P10', 'A01', 'Cuaderno',             'Scribe',        'Papelería',  10.00, 15.00, 24,  50,  5),
    ('P20', 'A01', 'Bolígrafo',            'Bic',           'Papelería',   1.20,  2.00, 65, 100, 10),
    ('P30', 'A01', 'Borrador',             'Faber-Castell', 'Papelería',   1.80,  3.00, 32,  60,  8),
    ('P40', 'A01', 'Regla 30 cm',          'Maped',         'Papelería',   1.50,  2.50, 18,  20,  5),
    ('P50', 'A01', 'Marcador permanente',  'Faber-Castell', 'Papelería',   2.50,  4.00,  6,   0,  6),
    ('P60', 'A01', 'Tijera escolar',       'Maped',         'Papelería',   4.00,  6.00,  5,  12,  5);

-- ---------------------------------------------------------------------
-- Ventas (MONTO_TOTAL inicia en 0 y lo actualizan los triggers)
-- ---------------------------------------------------------------------
INSERT INTO VENTA (id_venta, id_cliente, id_metodo, fecha_hora) VALUES
    ('V001', 'CLI01', 'M01', '2026-04-10 10:30:00'),
    ('V002', 'CLI02', 'M02', '2026-04-10 10:40:00'),
    ('V003', 'CLI00', 'M01', '2026-04-10 11:15:00'),
    ('V004', 'CLI01', 'M02', '2026-04-10 16:05:00'),
    ('V005', 'CLI02', 'M01', '2026-04-11 09:20:00');

-- PRECIO_UNITARIO se copia del PRECIO_VENTA vigente (precio congelado)
INSERT INTO DETALLE_VENTA (id_detalle, id_venta, id_producto, cantidad, precio_unitario) VALUES
    ('D01', 'V001', 'P10',  2, 15.00),   -- 30.00
    ('D02', 'V001', 'P20',  5,  2.00),   -- 10.00  -> V001 = 40.00
    ('D03', 'V002', 'P30',  1,  3.00),   --  3.00  -> V002 =  3.00
    ('D04', 'V003', 'P10',  2, 15.00),   -- 30.00
    ('D05', 'V003', 'P40',  3,  2.50),   --  7.50  -> V003 = 37.50
    ('D06', 'V004', 'P20', 10,  2.00),   -- 20.00
    ('D07', 'V004', 'P50',  2,  4.00),   --  8.00  -> V004 = 28.00
    ('D08', 'V005', 'P30',  1,  3.00),   --  3.00
    ('D09', 'V005', 'P60',  2,  6.00);   -- 12.00  -> V005 = 15.00
