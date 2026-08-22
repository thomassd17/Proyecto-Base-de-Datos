# Transcripción de Entrevista y Levantamiento de Requerimientos

**Fecha:** 22 de agosto de 2026  
**Entrevistador:** Estudiante de Ingeniería de Sistemas  
**Entrevistada:** Sra. Natalia Guzmán (Propietaria de Tienda "Natalia")  
**Objetivo:** Levantar información y requerimientos para el diseño de un sistema de base de datos para el control de inventario y ventas.

---

## 1. Transcripción de la Entrevista

**Entrevistador:** Hola abuela Natalia, gracias por darme este tiempo. Como te comentaba, para un proyecto de la universidad necesito analizar un negocio real para diseñarle una base de datos. Quería preguntarte, ¿cómo manejas actualmente la tienda y el registro de tus artículos?

**Sra. Natalia Guzmán:** Hola hijito. Mira, yo tengo mi tiendita donde vendo de todo un poco: víveres, artículos de papelería, aseo y cosas variadas. Para el control, la verdad es que manejo todo en un cuaderno borrador. Cuando voy a comprar mercadería al mercado Chiriguano o a los comerciales del centro, anoto ahí cuánto me costó cada producto para saber a cuánto debo vender la unidad.

**Entrevistador:** Entiendo. ¿Y qué datos de los productos necesitas saber o revisar siempre para que no haya confusiones?

**Sra. Natalia Guzmán:** Lo importante para mí es el nombre del producto, la marca o presentación, la categoría, el precio al que lo compré en el mercado, el precio al que lo voy a vender al público y la cantidad que me queda exhibida en los estantes. Como la tienda es pequeña y no tengo depósito, todo lo que tengo está directo en los estantes. A veces no sé si algún producto ya se terminó hasta que me fijo bien en las repisas.

**Entrevistador:** Claro, eso se resuelve controlando la cantidad de unidades en tiempo real. En cuanto a las ventas diarias, ¿cómo realizas el cobro y el registro de lo que compran los clientes?

**Sra. Natalia Guzmán:** Aquí toda venta es al contado. Cobro en efectivo o también mediante pago por QR. No entrego ningún tipo de comprobante, ni factura ni notas de venta impresas. La gente entra, pide sus productos, yo sumo los precios en la calculadora, me pagan y listo. Lo que me gustaría es saber al final del día cuánto vendí en total, cuánto cobré en efectivo, cuánto por QR y qué productos salieron más.

**Entrevistador:** Súper claro. Y sobre las compras para surtir la tienda, ¿cómo las realizas?

**Sra. Natalia Guzmán:** Yo voy directamente a los mercados mayoristas a comprar al contado todo lo que me hace falta para llenar los estantes. Me serviría mucho que el sistema me avise cuando a un producto le queden pocas unidades en el estante para anotarlo en mi lista antes de ir al mercado.

---

## 2. Análisis del Modelo Entidad-Relación (MER)

### A. Entidades y Atributos

#### `PRODUCTO`
Representa la mercadería exhibida directamente en los estantes.
* `id_producto` (Clave Primaria / PK)
* `nombre`
* `marca`
* `categoria`
* `precio_compra`
* `precio_venta`
* `stock_estante`
* `stock_minimo`

#### `METODO_PAGO`
Catálogo de formas de cobro aceptadas en caja.
* `id_metodo` (Clave Primaria / PK)
* `descripcion` *(Ej. "Efectivo", "QR")*

#### `VENTA`
Registra el encabezado de cada transacción.
* `id_venta` (Clave Primaria / PK)
* `fecha_hora`
* `monto_total`

#### `DETALLE_VENTA`
Entidad intermedia para resolver la relación $N:M$ entre `VENTA` y `PRODUCTO`.
* `id_detalle` (Clave Primaria / PK)
* `id_venta` (Clave Foránea / FK)
* `id_producto` (Clave Foránea / FK)
* `cantidad`
* `precio_unitario`
* `subtotal`

---

### B. Relaciones y Cardinalidades

1. **VENTA — METODO_PAGO (`tiene_metodo`)**
   * Cardinalidad: $(1:N)$
   * Una `VENTA` se realiza con exactamente un `METODO_PAGO` $(1,1)$.
   * Un `METODO_PAGO` puede aplicarse a una o muchas `VENTA`s $(1,N)$.

2. **VENTA — PRODUCTO (`contiene`)**
   * Cardinalidad: $(N:M)$
   * Una `VENTA` incluye uno o más `PRODUCTO`s $(1,N)$.
   * Un `PRODUCTO` puede venderse en cero o muchas `VENTA`s $(0,N)$.

---

### C. Diagrama Conceptual Textual

```text
[ METODO_PAGO ] (1) <--- (tiene_metodo) ---> (N) [ VENTA ]
                                                     |
                                                    (1)
                                                     |
                                               (contiene)
                                                     |
                                                    (N)
                                                     |
                                            [ DETALLE_VENTA ]
                                                     |
                                                    (N)
                                                     |
                                               (pertenece)
                                                     |
                                                    (1)
                                                     |
                                               [ PRODUCTO ]
```
![Diagrama Entidad Relación]
<img width="603" height="1075" alt="DiagramaER" src="https://github.com/user-attachments/assets/7895eb9b-e1af-4ef1-ac8b-921cfa523273" />

