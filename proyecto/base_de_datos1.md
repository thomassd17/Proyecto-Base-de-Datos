# Inventario y Ventas — Tienda "Natalia"

**Título:** Sistema de Gestión de Inventario y Ventas — Tienda "Natalia"

**Narración del cliente:**
"Soy la Sra. Natalia Guzmán, propietaria de la Tienda Natalia. Vendo papelería y artículos variados. Al ser un negocio de venta minorista al por menor, todas nuestras ventas son al contado (efectivo o QR) y no emitimos facturas fiscales. Actualmente anoto todo en un cuaderno borrador cuando voy a comprar mercadería a los mercados mayoristas para saber a cuánto debo vender la unidad. Necesito un sistema para controlar el stock de los productos que tengo exhibidos en los estantes y en el depósito o almacén de respaldo. Para cada venta se debe registrar un cliente para llevar un control e historial de compras, aunque no se emita factura por el tipo de negocio minorista. Necesito registrar el nombre, marca, categoría, precio de compra, precio de venta, las unidades en estante y en almacén. Al final del día quiero saber cuánto vendí en total, cuánto cobré en efectivo, cuánto por QR y qué productos tuvieron más salida. Además, necesito que el sistema me avise cuando a un producto le queden pocas unidades para incluirlo en mi lista de compras."

---

**Suposiciones:**
1. No se emiten facturas fiscales debido a que el negocio opera bajo la modalidad de **comercio minorista de venta rápida al contado**. Sin embargo, se incluye la entidad `CLIENTE` exclusivamente para el registro, control e historial de transacciones comerciales.
2. Se diferencian los atributos `STOCK ESTANTE` (exhibición para venta rápida) y `STOCK ALMACEN` (depósito de reserva) vinculados a la entidad `ALMACEN`.
3. Una venta puede contener varios productos y un producto puede comercializarse en múltiples ventas (relación N:M resolviéndose mediante la entidad intermedia `DETALLE VENTA`).
4. Los precios de venta unitarios se fijan en el momento del registro en `DETALLE VENTA` para mantener el historial ante variaciones futuras de precios.
5. Como cada venta exige un cliente (cardinalidad 1..1), se registra un cliente genérico `CLIENTE MOSTRADOR` para las ventas en las que la persona no desea dar sus datos.
6. `STOCK ALMACEN` se guarda dentro de `PRODUCTO`, por lo que cada producto se custodia en un único almacén (`ID ALMACEN`). Si en el futuro hubiera varios depósitos con el mismo producto, se crearía una tabla `INVENTARIO (ID PRODUCTO, ID ALMACEN, STOCK)`.
7. `SUBTOTAL` (`CANTIDAD` × `PRECIO UNITARIO`) y `MONTO_TOTAL` (suma de subtotales) son atributos derivados que se conservan por practicidad en los reportes de cierre del día; el sistema debe mantenerlos consistentes.
8. Los identificadores son códigos de texto (por ejemplo `CLI01`, `M01`, `A01`, `P10`, `V001`, `D01`).

---

**Entidades y atributos (modelo conceptual):**

* **CLIENTE**
  * `ID CLIENTE` (PK)
  * `NOMBRE`
  * `TELEFONO`

* **ALMACEN**
  * `ID ALMACEN` (PK)
  * `NOMBRE ALMACEN`
  * `UBICACION`

* **METODO_DE_PAGO**
  * `ID METODO` (PK)
  * `DESCRIPCION`

* **VENTA**
  * `ID VENTA` (PK)
  * `FECHA_HORA`
  * `MONTO_TOTAL` (derivado: suma de los `SUBTOTAL` de la venta)
  * `ID CLIENTE` (FK → CLIENTE)
  * `ID METODO` (FK → METODO_DE_PAGO)

* **DETALLE VENTA**
  * `ID DETALLE` (PK)
  * `ID VENTA` (FK → VENTA)
  * `ID PRODUCTO` (FK → PRODUCTO)
  * `CANTIDAD`
  * `PRECIO UNITARIO`
  * `SUBTOTAL` (derivado: `CANTIDAD` × `PRECIO UNITARIO`)
  * Restricción: `UNIQUE (ID VENTA, ID PRODUCTO)` (equivale a la clave compuesta definida en 1FN)

* **PRODUCTO**
  * `ID PRODUCTO` (PK)
  * `ID ALMACEN` (FK → ALMACEN)
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

* **CLIENTE (0..N) — REALIZA — (1..1) VENTA**
  * Un cliente puede realizar varias ventas (o ninguna todavía); cada venta es efectuada por un único cliente.

* **METODO_DE_PAGO (0..N) — SE_APLICA_EN — (1..1) VENTA**
  * Un método de pago puede utilizarse en muchas ventas; cada venta requiere un único método de pago.

* **ALMACEN (0..N) — GUARDA — (1..1) PRODUCTO**
  * Un almacén/depósito guarda uno o muchos productos (o ninguno todavía); cada producto pertenece a un único almacén.

* **VENTA (1..1) — POSEE — (1..N) DETALLE VENTA**
  * Una venta posee uno o varios detalles de venta; cada detalle pertenece a una única venta.

* **PRODUCTO (1..1) — INCLUYE — (0..N) DETALLE VENTA**
  * Un producto puede ser incluido en muchos detalles de venta (o en ninguno si aún no se vendió); cada detalle corresponde a un único producto.

---

**Restricciones de negocio importantes:**
1. **Validación de stock disponible:** Al registrar un ítem en `DETALLE VENTA`, se debe verificar que la `CANTIDAD` solicitada sea menor o igual al `STOCK ESTANTE` actual del `PRODUCTO`.
2. **Actualización automática de inventario:** Toda inserción en `DETALLE VENTA` descontará automáticamente las unidades del valor de `STOCK ESTANTE` en `PRODUCTO`.
3. **Alerta de reabastecimiento:** Si `STOCK ESTANTE` es menor o igual a `STOCK MIN`, se notifica la necesidad de reponer el estante. Si `STOCK ALMACEN` tiene unidades, se sugiere transferirlas al estante; si `STOCK ESTANTE + STOCK ALMACEN` es menor o igual a `STOCK MIN`, el producto se incluye en la lista de compras mayoristas.

---

**Diagrama Entidad-Relación (DER):**

Cada entidad se muestra con sus atributos; `PK` indica clave primaria y `FK` clave foránea. Las cardinalidades se leen en notación de "pata de gallo".

<img width="797" height="1097" alt="image" src="https://github.com/user-attachments/assets/3c11be2e-2839-4ea5-b3e6-ffacd5cfa08d" />

**Diagrama de clases (UML):**

<img width="838" height="1021" alt="image" src="https://github.com/user-attachments/assets/0cb96d50-7474-43c0-b805-14e2174d52ca" />

