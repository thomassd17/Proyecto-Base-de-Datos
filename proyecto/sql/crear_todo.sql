-- =====================================================================
-- Tienda "Natalia" — Sistema de Inventario y Ventas
-- INF312 Base de Datos I — Hito Unidad IV  (versión MySQL / MariaDB)
-- crear_todo.sql : UN SOLO PASO = 01_ddl.sql + 02_triggers.sql
--
-- Hace, en este orden:
--   1. Crea la base tienda_natalia si no existe y la selecciona.
--   2. Borra las tablas del proyecto si ya existen (DROP TABLE IF EXISTS).
--   3. Crea las 6 tablas y sus índices (vacías, listas para poblar).
--   4. Crea los triggers (stock, monto total y protección de detalles).
--
-- IMPORTANTE: usa DELIMITER para los triggers. Ejecútalo con el cliente
--   mysql (terminal de VS Code):  mysql -u root -p < crear_todo.sql
-- Si tu extensión de VS Code no entiende DELIMITER, ejecuta 01_ddl.sql con
-- la extensión y 02_triggers.sql desde la terminal.
-- Este archivo se genera juntando 01_ddl.sql y 02_triggers.sql.
-- =====================================================================

-- =====================================================================
-- Tienda "Natalia" — Sistema de Inventario y Ventas
-- INF312 Base de Datos I — Hito Unidad IV  (versión MySQL / MariaDB)
-- 01_ddl.sql : estructura (tablas e índices)
--
-- Este script se puede ejecutar cuantas veces quieras: si las tablas ya
-- existen, PRIMERO las borra (DROP TABLE IF EXISTS) y luego las crea de
-- nuevo, vacías. Solo toca las 6 tablas del proyecto, no la base de datos.
--
-- Requisitos: MySQL 8.0.16+ (o MariaDB 10.2.1+). Antes de 8.0.16 las
-- restricciones CHECK se aceptan pero NO se aplican.
-- Orden de ejecución: 01_ddl, 02_triggers, 03_datos, 04_vistas, 05_consultas
-- (o solo crear_todo.sql para ejecutar 01 + 02 de una vez).
-- =====================================================================

-- Crea la base de datos solo si no existe y la selecciona.
-- Si tu servidor ya te da una base asignada (hosting), comenta estas dos
-- sentencias con -- y selecciona tu base en la herramienta.
CREATE DATABASE IF NOT EXISTS tienda_natalia
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tienda_natalia;

SET NAMES utf8mb4;

-- Limpieza ANTES de crear: borra las tablas si ya existen
-- (orden inverso a las dependencias, porque las hijas apuntan a las padres).
-- Al borrar las tablas también se borran sus triggers.
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
    id_cliente  VARCHAR(10)  NOT NULL,
    nombre      VARCHAR(100) NOT NULL,
    telefono    VARCHAR(20),
    PRIMARY KEY (id_cliente)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE METODO_DE_PAGO (
    id_metodo    VARCHAR(10) NOT NULL,
    descripcion  VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_metodo),
    UNIQUE KEY uq_metodo_descripcion (descripcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ALMACEN (
    id_almacen      VARCHAR(10)  NOT NULL,
    nombre_almacen  VARCHAR(80)  NOT NULL,
    ubicacion       VARCHAR(120),
    PRIMARY KEY (id_almacen)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE PRODUCTO (
    id_producto    VARCHAR(10)   NOT NULL,
    id_almacen     VARCHAR(10)   NOT NULL,
    nombre         VARCHAR(100)  NOT NULL,
    marca          VARCHAR(60),
    categoria      VARCHAR(60),
    precio_compra  DECIMAL(10,2) NOT NULL,
    precio_venta   DECIMAL(10,2) NOT NULL,
    stock_estante  INT           NOT NULL DEFAULT 0,
    stock_almacen  INT           NOT NULL DEFAULT 0,
    stock_min      INT           NOT NULL DEFAULT 0,
    PRIMARY KEY (id_producto),
    CONSTRAINT ck_producto_precio_compra CHECK (precio_compra > 0),
    CONSTRAINT ck_producto_precio_venta  CHECK (precio_venta  > 0),
    CONSTRAINT ck_producto_stock_estante CHECK (stock_estante >= 0),
    CONSTRAINT ck_producto_stock_almacen CHECK (stock_almacen >= 0),
    CONSTRAINT ck_producto_stock_min     CHECK (stock_min     >= 0),
    CONSTRAINT fk_producto_almacen FOREIGN KEY (id_almacen)
        REFERENCES ALMACEN (id_almacen)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE VENTA (
    id_venta     VARCHAR(10)   NOT NULL,
    id_cliente   VARCHAR(10)   NOT NULL,
    id_metodo    VARCHAR(10)   NOT NULL,
    fecha_hora   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Derivado: lo mantienen los triggers como suma de los subtotales
    monto_total  DECIMAL(10,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (id_venta),
    CONSTRAINT ck_venta_monto CHECK (monto_total >= 0),
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
        REFERENCES CLIENTE (id_cliente)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_venta_metodo FOREIGN KEY (id_metodo)
        REFERENCES METODO_DE_PAGO (id_metodo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE DETALLE_VENTA (
    id_detalle       VARCHAR(10)   NOT NULL,
    id_venta         VARCHAR(10)   NOT NULL,
    id_producto      VARCHAR(10)   NOT NULL,
    cantidad         INT           NOT NULL,
    -- Precio "congelado" al momento de la venta (no cambia si PRODUCTO cambia)
    precio_unitario  DECIMAL(10,2) NOT NULL,
    -- Derivado: siempre consistente porque lo calcula el propio motor
    subtotal         DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
    PRIMARY KEY (id_detalle),
    UNIQUE KEY uq_detalle_venta_producto (id_venta, id_producto),
    CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT ck_detalle_precio   CHECK (precio_unitario > 0),
    CONSTRAINT fk_detalle_venta FOREIGN KEY (id_venta)
        REFERENCES VENTA (id_venta)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto)
        REFERENCES PRODUCTO (id_producto)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- ÍNDICES (FK y columnas usadas en filtros frecuentes)
-- UNIQUE (id_venta, id_producto) ya indexa id_venta en DETALLE_VENTA.
-- ---------------------------------------------------------------------

CREATE INDEX idx_producto_almacen  ON PRODUCTO (id_almacen);
CREATE INDEX idx_producto_nombre   ON PRODUCTO (nombre);
CREATE INDEX idx_venta_cliente     ON VENTA (id_cliente);
CREATE INDEX idx_venta_metodo      ON VENTA (id_metodo);
CREATE INDEX idx_venta_fecha       ON VENTA (fecha_hora);
CREATE INDEX idx_detalle_producto  ON DETALLE_VENTA (id_producto);

-- =====================================================================
-- PARTE 2: TRIGGERS
-- =====================================================================

-- =====================================================================
-- 02_triggers.sql : reglas de negocio (versión MySQL / MariaDB)
--
-- IMPORTANTE: este archivo usa DELIMITER. Funciona en el cliente `mysql`,
-- MySQL Workbench, DBeaver y phpMyAdmin (pestaña SQL). Si tu herramienta
-- no entiende DELIMITER, ejecuta cada trigger por separado, sin las
-- líneas DELIMITER y cambiando el "$$" final por ";".
-- =====================================================================

SET NAMES utf8mb4;

DELIMITER $$

DROP TRIGGER IF EXISTS trg_detalle_valida_stock$$
DROP TRIGGER IF EXISTS trg_detalle_descuenta_stock$$
DROP TRIGGER IF EXISTS trg_detalle_restituye_stock$$
DROP TRIGGER IF EXISTS trg_detalle_no_editable$$
DROP TRIGGER IF EXISTS trg_monto_total_insert$$
DROP TRIGGER IF EXISTS trg_monto_total_delete$$
DROP TRIGGER IF EXISTS trg_venta_restituye_stock_al_borrar$$

-- Regla 1: validar que la cantidad no supere el STOCK_ESTANTE
CREATE TRIGGER trg_detalle_valida_stock
BEFORE INSERT ON DETALLE_VENTA
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;

    SELECT stock_estante INTO v_stock
    FROM PRODUCTO
    WHERE id_producto = NEW.id_producto
    FOR UPDATE;                      -- bloquea la fila mientras dura la venta

    IF v_stock IS NOT NULL AND v_stock < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente en estante';
    END IF;
END$$

-- Regla 2: descontar automáticamente el STOCK_ESTANTE
CREATE TRIGGER trg_detalle_descuenta_stock
AFTER INSERT ON DETALLE_VENTA
FOR EACH ROW
BEGIN
    UPDATE PRODUCTO
    SET stock_estante = stock_estante - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END$$

-- Si se elimina un renglón (devolución/anulación), el stock vuelve al estante
CREATE TRIGGER trg_detalle_restituye_stock
AFTER DELETE ON DETALLE_VENTA
FOR EACH ROW
BEGIN
    UPDATE PRODUCTO
    SET stock_estante = stock_estante + OLD.cantidad
    WHERE id_producto = OLD.id_producto;
END$$

-- En MySQL el borrado en cascada (ON DELETE CASCADE) NO activa triggers.
-- Por eso, al borrar una venta completa se devuelve el stock aquí.
CREATE TRIGGER trg_venta_restituye_stock_al_borrar
BEFORE DELETE ON VENTA
FOR EACH ROW
BEGIN
    UPDATE PRODUCTO p
    JOIN DETALLE_VENTA d ON d.id_producto = p.id_producto
    SET p.stock_estante = p.stock_estante + d.cantidad
    WHERE d.id_venta = OLD.id_venta;
END$$

-- Un renglón no se edita: se elimina y se registra de nuevo
-- (así el stock y el monto nunca quedan inconsistentes)
CREATE TRIGGER trg_detalle_no_editable
BEFORE UPDATE ON DETALLE_VENTA
FOR EACH ROW
BEGIN
    IF NOT (NEW.cantidad <=> OLD.cantidad)
       OR NOT (NEW.id_producto <=> OLD.id_producto)
       OR NOT (NEW.precio_unitario <=> OLD.precio_unitario) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Un detalle no se modifica: eliminelo y registrelo de nuevo';
    END IF;
END$$

-- MONTO_TOTAL (derivado) = suma de subtotales de la venta
CREATE TRIGGER trg_monto_total_insert
AFTER INSERT ON DETALLE_VENTA
FOR EACH ROW
BEGIN
    UPDATE VENTA
    SET monto_total = (SELECT COALESCE(SUM(subtotal), 0)
                       FROM DETALLE_VENTA WHERE id_venta = NEW.id_venta)
    WHERE id_venta = NEW.id_venta;
END$$

CREATE TRIGGER trg_monto_total_delete
AFTER DELETE ON DETALLE_VENTA
FOR EACH ROW
BEGIN
    UPDATE VENTA
    SET monto_total = (SELECT COALESCE(SUM(subtotal), 0)
                       FROM DETALLE_VENTA WHERE id_venta = OLD.id_venta)
    WHERE id_venta = OLD.id_venta;
END$$

DELIMITER ;
