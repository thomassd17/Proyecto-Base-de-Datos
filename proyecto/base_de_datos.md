# Inventario y Ventas — Tienda "Natalia"

**Título:** Sistema de Gestión de Inventario y Ventas — Tienda "Natalia"

**Narración del cliente:**
"Soy la Sra. Natalia Guzmán, propietaria de la Tienda Natalia. Vendo papelería y artículos variados. Actualmente anoto todo en un cuaderno borrador cuando voy a comprar mercadería a los mercados mayoristas para saber a cuánto debo vender la unidad. Necesito un sistema para controlar el stock de los productos que tengo exhibidos en los estantes y en el depósito o almacén de respaldo. Para cada venta se debe registrar un cliente para llevar un control e historial de compras, aunque no se emita factura. Necesito registrar el nombre, marca, categoría, precio de compra, precio de venta, las unidades en estante y en almacén. Toda venta es al contado y se paga en efectivo o por QR. Al final del día quiero saber cuánto vendí en total, cuánto cobré en efectivo, cuánto por QR y qué productos tuvieron más salida. Además, necesito que el sistema me avise cuando a un producto le queden pocas unidades para incluirlo en mi lista de compras."

---

**Suposiciones:**
1. Se incluye la entidad `CLIENTE` para el registro y seguimiento comercial de cada transacción, sin implicar fines de facturación fiscal.
2. Se diferencian los atributos `STOCK ESTANTE` (exhibición para venta rápida) y `STOCK ALMACEN` (depósito de reserva) vinculados a la entidad `ALMACEN`.
3. Una venta puede contener varios productos y un producto puede comercializarse en múltiples ventas (relación N:M resolviéndose mediante la entidad intermedia `DETALLE VENTA`).
4. Los precios de venta unitarios se fijan en el momento del registro en `DETALLE VENTA` para mantener el historial ante variaciones futuras de precios.

---

**Entidades y atributos (modelo conceptual):**

* **CLIENTE**
  * `ID CLIENTE` (PK)
  * `NOMBRE`

* **ALMACEN**
  * `ID ALMACEN` (PK)
  * `NOMBRE ALMACEN`

* **METODO_DE_PAGO**
  * `ID METODO` (PK)
  * `DESCRIPCION`

* **VENTA**
  * `ID VENTA` (PK)
  * `FECHA_HORA`
  * `MONTO_TOTAL`
  * `ID CLIENTE` (FK → CLIENTE)
  * `ID METODO` (FK → METODO_DE_PAGO)

* **DETALLE VENTA**
  * `ID DETALLE` (PK)
  * `ID VENTA` (FK → VENTA)
  * `ID PRODUCTO` (FK → PRODUCTO)
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
  * `STOCK ALMACEN`
  * `STOCK MIN`

---

**Relaciones y cardinalidades (justificación):**

* **CLIENTE (1..1) — REALIZA — (1..N) VENTA**
  * Un cliente realiza una o varias ventas en el sistema; cada venta es efectuada obligatoriamente por un único cliente.

* **METODO_DE_PAGO (1..1) — TIENE — (1..N) VENTA**
  * Un método de pago puede utilizarse en una o muchas ventas; cada venta requiere obligatoriamente un único método de pago.

* **ALMACEN (1..1) — GUARDA — (1..N) PRODUCTO**
  * Un almacén/depósito guarda o custodia uno o muchos productos; cada producto pertenece al registro de un almacén.

* **VENTA (1..1) — POSEE — (1..N) DETALLE VENTA**
  * Una venta posee uno o varios detalles de venta; cada detalle pertenece a una única venta.

* **PRODUCTO (1..1) — INCLUYE — (1..N) DETALLE VENTA**
  * Un producto puede ser incluido en uno o varios detalles de venta; cada detalle corresponde a un único producto.

---

**Restricciones de negocio importantes:**
1. **Validación de stock disponible:** Al registrar un ítem en `DETALLE VENTA`, se debe verificar que la `CANTIDAD` solicitada sea menor o igual al `STOCK ESTANTE` actual del `PRODUCTO`.
2. **Actualización automática de inventario:** Toda inserción en `DETALLE VENTA` descontará automáticamente las unidades del valor de `STOCK ESTANTE` en `PRODUCTO`.
3. **Alerta de reabastecimiento:** Si `STOCK ESTANTE` es menor o igual a `STOCK MIN`, el producto debe ser notificado para reposición desde el `STOCK ALMACEN` o compra mayorista.

---

**Representación para DER:**
* **Entidades (Rectángulos):** `CLIENTE`, `ALMACEN`, `METODO_DE_PAGO`, `VENTA`, `DETALLE VENTA`, `PRODUCTO`.
* **Relaciones (Rombos):** `REALIZA`, `GUARDA`, `TIENE`, `POSEE`, `INCLUYE`.
* **Atributos (Elipses):** Representan los campos de cada entidad, destacando los identificadores clave PK (subrayados) y las FK para asegurar la trazabilidad.

<img width="822" height="792" alt="image" src="https://github.com/user-attachments/assets/2cd3d356-e048-4f07-801c-ed5c7a30068d" />


