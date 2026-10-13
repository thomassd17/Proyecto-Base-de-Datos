# 🛒 Sistema de Gestión de Inventario y Ventas — Tienda "Natalia"

Sistema de control de inventario y registro de ventas enfocado en comercios minoristas de venta directa al contado. El proyecto resuelve la necesidad de trazabilidad de productos entre exhibición y depósito, gestión de clientes sin fines de facturación tributaria y automatización de alertas de reabastecimiento.

---

## 📄 Vista General del Proyecto

* **Módulo Principal (Core):** Gestión de Ventas diarias al contado (Efectivo y QR), registro de clientes para historial de compras e integración de detalles de venta con precios congelados dinámicamente.
* **Módulo Secundario:** Gestión de Inventario multinivel (diferenciando `STOCK ESTANTE` y `STOCK ALMACEN`) y alertas de stock mínimo para compras mayoristas.
* **Materia:** INF312 — Base de Datos I.

---

## 📝 Documentación Conceptual (`base_de_datos1.md`)

### Narración del Cliente
> *"Soy la Sra. Natalia Guzmán, propietaria de la Tienda Natalia. Vendo papelería y artículos variados. Al ser un negocio de venta minorista al por menor, todas nuestras ventas son al contado (efectivo o QR) y no emitimos facturas fiscales. Actualmente anoto todo en un cuaderno borrador cuando voy a comprar mercadería a los mercados mayoristas para saber a cuánto debo vender la unidad. Necesito un sistema para controlar el stock de los productos que tengo exhibidos en los estantes y en el depósito o almacén de respaldo. Para cada venta se debe registrar un cliente para llevar un control e historial de compras, aunque no se emita factura por el tipo de negocio minorista. Necesito registrar el nombre, marca, categoría, precio de compra, precio de venta, las unidades en estante y en almacén. Al final del día quiero saber cuánto vendí en total, cuánto cobré en efectivo, cuánto por QR y qué productos tuvieron más salida. Además, necesito que el sistema me avise cuando a un producto le queden pocas unidades para incluirlo en mi lista de compras."*

### Suposiciones del Dominio
1. **Facturación e Historial:** No se emiten facturas fiscales debido a la modalidad de comercio minorista de venta rápida. Se incluye la entidad `CLIENTE` para mantener la trazabilidad e historial comercial.
2. **Control de Inventario:** Se dividen las existencias en `STOCK_ESTANTE` (disponibilidad para venta inmediata) y `STOCK_ALMACEN` (depósito de reserva asignado).
3. **Persistencia de Precios:** Los precios de venta unitarios se fijan en el momento exacto del registro en `DETALLE_VENTA` para asegurar el valor histórico frente a futuras fluctuaciones en `PRODUCTO`.
4. **Cliente obligatorio y "Cliente mostrador":** Como cada venta exige un cliente (cardinalidad 1..1), se registra un cliente genérico llamado `CLIENTE MOSTRADOR` para las ventas en las que la persona no desea dar sus datos.
5. **Un solo almacén por producto:** `STOCK_ALMACEN` se guarda dentro de `PRODUCTO`, por lo que cada producto se custodia en un único almacén (`ID_ALMACEN`). Si en el futuro el negocio usara varios depósitos con el mismo producto, se crearía una tabla `INVENTARIO (ID_PRODUCTO, ID_ALMACEN, STOCK)`.
6. **Atributos derivados:** `SUBTOTAL` (`CANTIDAD` × `PRECIO_UNITARIO`) y `MONTO_TOTAL` (suma de subtotales de la venta) se conservan por practicidad en los reportes de cierre del día, pero se pueden recalcular; el sistema debe mantenerlos consistentes al registrar cada venta.

---

## 📊 Modelo Entidad-Relación (DER )

El siguiente diagrama representa las entidades, atributos principales, claves foráneas (FK) y cardinalidades del sistema:

![Diagrama Entidad Relación](https://github.com/user-attachments/assets/2cd3d356-e048-4f07-801c-ed5c7a30068d)

---

## 🗄️ Esquema de Entidades y Relaciones

### Entidades y Atributos

* **`CLIENTE`**
  * `ID_CLIENTE` (PK)
  * `NOMBRE`
* **`ALMACEN`**
  * `ID_ALMACEN` (PK)
  * `NOMBRE_ALMACEN`
* **`METODO_DE_PAGO`**
  * `ID_METODO` (PK)
  * `DESCRIPCION`
* **`VENTA`**
  * `ID_VENTA` (PK)
  * `FECHA_HORA`
  * `MONTO_TOTAL` (derivado: suma de los `SUBTOTAL` de la venta)
  * `ID_CLIENTE` (FK → `CLIENTE`)
  * `ID_METODO` (FK → `METODO_DE_PAGO`)
* **`DETALLE_VENTA`**
  * `ID_DETALLE` (PK)
  * `ID_VENTA` (FK → `VENTA`)
  * `ID_PRODUCTO` (FK → `PRODUCTO`)
  * `CANTIDAD`
  * `PRECIO_UNITARIO`
  * `SUBTOTAL` (derivado: `CANTIDAD` × `PRECIO_UNITARIO`)
  * Restricción: `UNIQUE (ID_VENTA, ID_PRODUCTO)`, para que un producto no se repita como renglón dentro de la misma venta (equivale a la clave compuesta definida en 1FN).
* **`PRODUCTO`**
  * `ID_PRODUCTO` (PK)
  * `ID_ALMACEN` (FK → `ALMACEN`)
  * `NOMBRE`
  * `MARCA`
  * `CATEGORIA`
  * `PRECIO_VENTA`
  * `PRECIO_COMPRA`
  * `STOCK_ESTANTE`
  * `STOCK_ALMACEN`
  * `STOCK_MIN`

### Cardinalidades Justificadas
* **`CLIENTE` (1..1) — `REALIZA` — (1..N) `VENTA`:** Un cliente efectúa una o más ventas; cada registro de venta pertenece a un único cliente.
* **`METODO_DE_PAGO` (1..1) — `TIENE` — (1..N) `VENTA`:** Un método de pago puede asociarse a múltiples ventas; cada venta asigna un único método.
* **`ALMACEN` (1..1) — `GUARDA` — (1..N) `PRODUCTO`:** Un almacén custodia múltiples productos; cada producto está asignado a un almacén.
* **`VENTA` (1..1) — `POSEE` — (1..N) `DETALLE_VENTA`:** Una venta se compone de uno o varios renglones/detalles de venta.
* **`PRODUCTO` (1..1) — `INCLUYE` — (1..N) `DETALLE_VENTA`:** Un producto puede ser vendido en uno o muchos detalles de venta.

---

## ⚙️ Reglas de Negocio Implementadas

1. **Validación de Unidades:** La cantidad ingresada en `DETALLE_VENTA` se valida contra el saldo de `STOCK_ESTANTE`.
2. **Deducción Automática:** Cada registro en `DETALLE_VENTA` decrementa automáticamente la existencia en `STOCK_ESTANTE`.
3. **Alerta de Reabastecimiento:** Si `STOCK_ESTANTE` $\le$ `STOCK_MIN`, el sistema notifica la necesidad de reponer el estante. Si `STOCK_ALMACEN` tiene unidades, se sugiere una transferencia del almacén al estante; si `STOCK_ESTANTE + STOCK_ALMACEN` $\le$ `STOCK_MIN`, el producto se incluye en la lista de compras mayoristas.

---

