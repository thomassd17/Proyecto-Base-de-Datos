# Caso de Estudio: Inventario y Ventas — Tienda "Natalia"

**Título:** Sistema de Gestión de Inventario y Ventas — Tienda "Natalia"

**Narración del cliente:**
"Soy la Sra. Natalia Guzmán, propietaria de la Tienda Natalia. Vendo víveres, papelería y artículos variados. Actualmente anoto todo en un cuaderno borrador cuando voy a comprar mercadería a los mercados mayoristas para saber a cuánto debo vender la unidad. Necesito un sistema para controlar el stock de los productos que tengo exhibidos en los estantes (no tengo depósito). Necesito registrar el nombre, marca, categoría, precio de compra, precio de venta y las unidades en estante. Toda venta es al contado y se paga en efectivo o por QR, sin emisión de facturas. Al final del día quiero saber cuánto vendí en total, cuánto cobré en efectivo, cuánto por QR y qué productos tuvieron más salida. Además, necesito que el sistema me avise cuando a un producto le queden pocas unidades para incluirlo en mi lista de compras."

---

**Suposiciones:**
1. No se registra información de los compradores (sin entidad CLIENTE) debido a la naturaleza de venta rápida al por menor.
2. El atributo `STOCK ESTANTE` representa el 100% de la existencia física del producto (ausencia de almacén secundario).
3. Una venta puede contener varios productos y un producto puede comercializarse en múltiples ventas (relación N:M resolviéndose mediante la entidad intermedia `DETALLE VENTA`).
4. Los precios de venta unitarios se fijan en el momento del registro en `DETALLE VENTA` para mantener el historial histórico ante variaciones de precios.

---

**Entidades y atributos (modelo conceptual):**

* **METODO_DE_PAGO**
  * `ID METODO` (PK)
  * `DESCRIPCION`

* **VENTA**
  * `ID VENTA` (PK)
  * `FECHA_HORA`
  * `MONTO_TOTAL`

* **DETALLE VENTA**
  * `ID DETALLE` (PK)
  * `CANTIDAD`
  * `PRECIO UNITARIO`
  * `SUBTOTAL`

* **PRODUCTO**
  * `ID PRODUCTO` (PK)
  * `NOMBRE`
  * `MARCA`
  * `CATEGORIA`
  * `PRECIO VENTA`
  * `PRECIO COMPRA`
  * `STOCK ESTANTE`
  * `STOCK MIN`

---

**Relaciones y cardinalidades (justificación):**

* **METODO_DE_PAGO (1..1) — TIENE — (1..N) VENTA**
  * Un método de pago puede utilizarse en una o muchas ventas; cada venta requiere obligatoriamente un único método de pago.

* **VENTA (1..1) — POSEE — (1..N) DETALLE VENTA**
  * Una venta posee uno o varios detalles de venta; cada detalle pertenece a una única venta.

* **PRODUCTO (1..1) — INCLUYE — (1..N) DETALLE VENTA**
  * Un producto puede ser incluido en uno o varios detalles de venta; cada detalle corresponde a un único producto.

---

**Restricciones de negocio importantes:**
1. **Validación de stock disponible:** Al registrar un ítem en `DETALLE VENTA`, se debe verificar que la `CANTIDAD` solicitada sea menor o igual al `STOCK ESTANTE` actual del `PRODUCTO`.
2. **Actualización automática de inventario:** Toda inserción en `DETALLE VENTA` descontará automáticamente las unidades del valor de `STOCK ESTANTE` en `PRODUCTO`.
3. **Alerta de reabastecimiento:** Si `STOCK ESTANTE` es menor o igual a `STOCK MIN`, el producto debe ser notificado para reposición mayorista.

---

**Representación para DER:**
* **Entidades (Rectángulos):** `METODO_DE_PAGO`, `VENTA`, `DETALLE VENTA`, `PRODUCTO`.
* **Relaciones (Rombos):** `TIENE`, `POSEE`, `INCLUYE`.
* **Atributos (Elipses):** Representan los campos de cada entidad, destacando los identificadores clave subrayados (`ID METODO`, `ID VENTA`, `ID DETALLE`, `ID PRODUCTO`).

![Diagrama Entidad Relación]<img width="802" height="702" alt="image" src="https://github.com/user-attachments/assets/039e7d79-a73f-405e-a0a7-54582bb804d5" />

---

## Mapeo Relacional (Modelo Relacional)

