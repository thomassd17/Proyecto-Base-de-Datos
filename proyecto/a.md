# Caso de Estudio: Inventario y Ventas — Tienda "Natalia"

**Título:** Sistema de Gestión de Inventario y Ventas — Tienda "Natalia"

**Narración del cliente:**
"Soy la Sra. Natalia Guzmán, propietaria de la Tienda Natalia. Vendo víveres, papelería y artículos variados. Actualmente anoto todo en un cuaderno borrador cuando voy a comprar mercadería a los mercados mayoristas para saber a cuánto debo vender la unidad. Necesito un sistema para controlar el stock de los productos que tengo exhibidos en los estantes (no tengo depósito). Necesito registrar el nombre, marca, categoría, precio de compra, precio de venta y las unidades en estante. Toda venta es al contado y se paga en efectivo o por QR, sin emisión de facturas. Al final del día quiero saber cuánto vendí en total, cuánto cobré en efectivo, cuánto por QR y qué productos tuvieron más salida. Además, necesito que el sistema me avise cuando a un producto le queden pocas unidades para incluirlo en mi lista de compras."

---

**Suposiciones:**
1. No se registra información de los compradores (sin entidad CLIENTE) debido a la naturaleza de venta rápida al por menor.
2. El atributo `stock_estante` representa el 100% de la existencia física del producto (ausencia de almacén secundario).
3. Una venta puede contener varios productos y un producto puede comercializarse en múltiples ventas (relación N:M resolviéndose mediante la entidad asociativa `DETALLE_VENTA`).
4. Los precios de venta unitarios se fijan en el momento del registro en `DETALLE_VENTA` para mantener el historial histórico ante variaciones de precios.

---

**Entidades y atributos (modelo conceptual):**

* **PRODUCTO**
  * `id_producto` (PK) — INTEGER
  * `nombre` VARCHAR(100) NOT NULL
  * `marca` VARCHAR(50)
  * `categoria` VARCHAR(50)
  * `precio_compra` DECIMAL(8,2) NOT NULL CHECK (precio_compra >= 0)
  * `precio_venta` DECIMAL(8,2) NOT NULL CHECK (precio_venta >= 0)
  * `stock_estante` INTEGER NOT NULL CHECK (stock_estante >= 0)
  * `stock_minimo` INTEGER NOT NULL DEFAULT 5

* **METODO_PAGO**
  * `id_metodo` (PK) — INTEGER
  * `descripcion` VARCHAR(30) CHECK (descripcion IN ('Efectivo', 'QR'))

* **VENTA**
  * `id_venta` (PK) — INTEGER
  * `fecha_hora` DATETIME DEFAULT CURRENT_TIMESTAMP
  * `monto_total` DECIMAL(10,2) NOT NULL CHECK (monto_total >= 0)
  * `id_metodo` (FK → METODO_PAGO)

* **DETALLE_VENTA** (entidad asociativa para N:M)
  * `id_detalle` (PK) — INTEGER
  * `id_venta` (FK → VENTA)
  * `id_producto` (FK → PRODUCTO)
  * `cantidad` INTEGER NOT NULL CHECK (cantidad > 0)
  * `precio_unitario` DECIMAL(8,2) NOT NULL
  * `subtotal` DECIMAL(10,2) NOT NULL

---

**Relaciones y cardinalidades (justificación):**

* **METODO_PAGO 1 — N VENTA**
  * Un método de pago (Efectivo o QR) puede ser utilizado en muchas ventas; cada venta se liquida mediante un único método de pago.

* **VENTA N — M PRODUCTO (implementada con DETALLE_VENTA)**
  * Una venta puede incluir uno o varios productos; un producto puede ser vendido en distintas ventas a lo largo del tiempo.

---

**Restricciones de negocio importantes:**
1. **Validación de stock disponible:** Al registrar un item en `DETALLE_VENTA`, se debe verificar que la `cantidad` solicitada sea menor o igual al `stock_estante` actual del `PRODUCTO`.
2. **Actualización automática de inventario:** Toda inserción en `DETALLE_VENTA` debe descontar automáticamente del valor de `stock_estante` en `PRODUCTO`.
3. **Alerta de reabastecimiento:** Si `stock_estante` <= `stock_minimo`, el producto se categoriza en estado crítico para la lista de reposición mayorista.

---

**Representación para DER:**
* **Entidades:** Rectángulos para `PRODUCTO`, `METODO_PAGO` y `VENTA`.
* **Entidad asociativa:** `DETALLE_VENTA` conectando `VENTA` con `PRODUCTO`.
* **Cardinalidades:** `METODO_PAGO` (1) — (N) `VENTA`; `VENTA` (1) — (N) `DETALLE_VENTA` (N) — (1) `PRODUCTO`.

<img width="802" height="702" alt="image" src="https://github.com/user-attachments/assets/039e7d79-a73f-405e-a0a7-54582bb804d5" />

## Mapeo Relacional (Modelo Relacional)

*(Pendiente de ejecución)*
