# Caso de Estudio: Sistema de Gestión de Inventario y Ventas - Tienda "Natalia"

---

## 1. Contexto del Dominio del Problema

La **Tienda "Natalia"**, ubicada en Santa Cruz de la Sierra y administrada por la Sra. Natalia Guzmán, es un negocio de comercio minorista que comercializa víveres, artículos de papelería, productos de aseo personal y artículos del hogar. 

Actualmente, la gestión operativa (control de existencias y registro de ventas) se realiza de forma manual mediante notas en un cuaderno borrador. Esta falta de automatización genera incertidumbres sobre el nivel de stock en tiempo real, dificulta la consolidación de ingresos al final de la jornada según la modalidad de pago y no ofrece mecanismos de alerta para el reabastecimiento oportunamente antes de realizar compras mayoristas.

El objetivo del proyecto es diseñar la base de datos relacional que permita automatizar el registro de transacciones, mantener un control riguroso de inventario en exhibición y facilitar el análisis de ingresos por tipo de pago.

---

## 2. Transcripción de la Entrevista (Levantamiento de Información)

**Fecha:** 22 de agosto de 2026  
**Entrevistador:** Estudiante de Ingeniería de Sistemas  
**Entrevistada:** Sra. Natalia Guzmán (Propietaria de Tienda "Natalia")  

* **Entrevistador:** Hola abuela Natalia, gracias por darme este tiempo. Para un proyecto de la universidad necesito analizar un negocio real para diseñarle una base de datos. Quería preguntarte, ¿cómo manejas actualmente la tienda y el registro de tus artículos?
* **Sra. Natalia Guzmán:** Hola hijito. Mira, yo tengo mi tiendita donde vendo de todo un poco: víveres, artículos de papelería, aseo y cosas variadas. Para el control, la verdad es que manejo todo en un cuaderno borrador. Cuando voy a comprar mercadería al mercado Chiriguano o a los comerciales del centro, anoto ahí cuánto me costó cada producto para saber a cuánto debo vender la unidad.
* **Entrevistador:** Entiendo. ¿Y qué datos de los productos necesitas saber o revisar siempre para que no haya confusiones?
* **Sra. Natalia Guzmán:** Lo importante para mí es el nombre del producto, la marca o presentación, la categoría, el precio al que lo compré en el mercado, el precio al que lo voy a vender al público y la cantidad que me queda exhibida en los estantes. Como la tienda es pequeña y no tengo depósito, todo lo que tengo está directo en los estantes. A veces no sé si algún producto ya se terminó hasta que me fijo bien en las repisas.
* **Entrevistador:** Claro, eso se resuelve controlando la cantidad de unidades en tiempo real. En cuanto a las ventas diarias, ¿cómo realizas el cobro y el registro de lo que compran los clientes?
* **Sra. Natalia Guzmán:** Aquí toda venta es al contado. Cobro en efectivo o también mediante pago por QR. No entrego ningún tipo de comprobante, ni factura ni notas de venta impresas. La gente entra, pide sus productos, yo sumo los precios en la calculadora, me pagan y listo. Lo que me gustaría es saber al final del día cuánto vendí en total, cuánto cobré en efectivo, cuánto por QR y qué productos salieron más.
* **Entrevistador:** Súper claro. Y sobre las compras para surtir la tienda, ¿cómo las realizas?
* **Sra. Natalia Guzmán:** Yo voy directamente a los mercados mayoristas a comprar al contado todo lo que me hace falta para llenar los estantes. Me serviría mucho que el sistema me avise cuando a un producto le queden pocas unidades en el estante para anotarlo en mi lista antes de ir al mercado.

---

## 3. Lista de Requisitos Funcionales y Reglas de Negocio

### A. Requisitos Funcionales (RF)
* **RF-01 (Gestión de Productos):** El sistema debe registrar, editar y listar los productos con su nombre, marca, categoría, precios y niveles de existencia.
* **RF-02 (Registro de Ventas):** El sistema debe permitir registrar una venta seleccionando uno o más productos, especificando la cantidad vendida y asignando la modalidad de pago.
* **RF-03 (Descuento Automático de Inventario):** Al confirmarse una venta, el sistema debe descontar automáticamente del inventario la cantidad comercializada de cada producto.
* **RF-04 (Consolidado por Método de Pago):** El sistema debe permitir consultar el total facturado filtrado por método de pago (Efectivo vs. QR) para el arqueo de caja diario.
* **RF-05 (Alerta de Reabastecimiento):** El sistema debe listar los productos cuyo stock actual sea menor o igual a su stock mínimo establecido.

### B. Reglas de Negocio (RN)
* **RN-01 (Ubicación Única de Inventario):** No existe almacén o depósito secundario. El campo `stock_estante` representa la totalidad física del inventario.
* **RN-02 (Formas de Cobro Restringidas):** Las únicas modalidades de cobro válidas en el sistema son **Efectivo** y **QR**. Toda venta es estrictamente al contado.
* **RN-03 (Sin Comprobantes ni Registro de Clientes):** Por la naturaleza del negocio, no se emiten facturas ni se registran datos personales de los clientes.
* **RN-04 (Validación de Stock):** No se puede procesar la venta de un producto si la cantidad solicitada supera las unidades disponibles en `stock_estante`.
* **RN-05 (Integridad Referencial):** No se permite la eliminación de productos o métodos de pago que estén vinculados a un historial de ventas existente.

---

## 4. Identificación de Entidades, Atributos y Claves

| Entidad | Descripción | Atributos | Clave Primaria (PK) | Claves Foráneas (FK) |
| :--- | :--- | :--- | :--- | :--- |
| **PRODUCTO** | Mercadería disponible en estantes para la venta. | `id_producto`, `nombre`, `marca`, `categoria`, `precio_compra`, `precio_venta`, `stock_estante`, `stock_minimo` | `id_producto` | Ninguna |
| **METODO_PAGO** | Catálogo de formas de cobro aceptadas en caja. | `id_metodo`, `descripcion` | `id_metodo` | Ninguna |
| **VENTA** | Encabezado de la transacción comercial. | `id_venta`, `fecha_hora`, `monto_total`, `id_metodo` | `id_venta` | `id_metodo` |
| **DETALLE_VENTA** | Entidad débil/intermedia que especifica los ítems de una venta. | `id_detalle`, `id_venta`, `id_producto`, `cantidad`, `precio_unitario`, `subtotal` | `id_detalle` | `id_venta`, `id_producto` |

---

## 5. Matriz de Relaciones y Cardinalidades

### 1. VENTA — METODO_PAGO (`tiene_metodo`)
* **Perspectiva VENTA:** Una venta debe procesarse utilizando **un único** método de pago $(1,1)$.
* **Perspectiva METODO_PAGO:** Un método de pago puede ser registrado en **una o muchas** ventas $(1,N)$.
* **Cardinalidad Global:** **$1:N$** (Uno a Muchos).

### 2. VENTA — PRODUCTO (`contiene`)
* **Perspectiva VENTA:** Una venta contiene **uno o varios** productos $(1,N)$.
* **Perspectiva PRODUCTO:** Un producto puede ser vendido en **cero o muchas** ventas $(0,N)$.
* **Cardinalidad Global:** **$N:M$** (Muchos a Muchos).  
  * *Resolución de $N:M$:* Se transforma creando la entidad intermedia **DETALLE_VENTA**.

---

## 6. Diagrama Entidad-Relación (DER)

<img width="603" height="1075" alt="DiagramaER" src="https://github.com/user-attachments/assets/7895eb9b-e1af-4ef1-ac8b-921cfa523273" />

---

## 7. Mapeo Relacional (Modelo Relacional)

*(Pendiente de ejecución según las indicaciones del docente para la siguiente fase del proyecto).*
