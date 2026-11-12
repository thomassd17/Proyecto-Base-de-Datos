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
