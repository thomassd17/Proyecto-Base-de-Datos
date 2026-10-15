# 📐 Proceso de Normalización — Tienda "Natalia"
**Proceso de normalización aplicado a la base de datos de la Tienda "Natalia", pasando por la Forma No Normalizada (0FN) hasta la Tercera Forma Normal (3FN) para eliminar redundancias y anomalías de actualización.**

**0FN (Forma No Normalizada) :**
Estado inicial correspondiente al registro manual en cuaderno borrador. Los productos vendidos en una misma transacción se encuentran agrupados en una sola celda como un atributo multivaluado.

<img width="1065" height="205" alt="image" src="https://github.com/user-attachments/assets/5f884486-ac68-4d0f-b467-72d579a3e5e2" />


**1FN (Primera Forma Normal) :**
 |Regla: Se eliminan los grupos repetitivos garantizando valores atómicos por celda y se define una clave primaria compuesta (ID_VENTA, ID_PRODUCTO).

<img width="1523" height="201" alt="image" src="https://github.com/user-attachments/assets/1ca68578-1fe6-4727-8ac4-adf58defcb40" />

**2FN (Segunda Forma Normal) :**
|Regla: Estar en 1FN y eliminar dependencias parciales. Todos los atributos no clave deben depender de la totalidad de la clave primaria (ID_VENTA, ID_PRODUCTO).

**Dependencias Funcionales Evaluadas :**
1.ID_VENTA -> FECHA_HORA, CLIENTE, METODO_PAGO, MONTO_TOTAL
2.ID_PRODUCTO -> NOMBRE_PRODUCTO, ALMACEN
3.(ID_VENTA, ID_PRODUCTO) -> CANTIDAD, PRECIO_UNITARIO, SUBTOTAL

**Estructura Tabular en 2FN :**
Tabla VENTA_2FN

<img width="761" height="175" alt="image" src="https://github.com/user-attachments/assets/b21f5628-1c56-4f19-ad4f-e6a30e5ef9fc" />

**Tabla PRODUCTO_2FN**

<img width="913" height="201" alt="image" src="https://github.com/user-attachments/assets/18ec277b-1d34-4e10-96db-cc8b7a271cfa" />

**Tabla DETALLE_VENTA_2FN**

<img width="913" height="201" alt="image" src="https://github.com/user-attachments/assets/57365c01-5aed-44ec-acee-47d89438cdc5" />

**3FN (Tercera Forma Normal)**
**Regla aplicada:** Estar en 1FN y eliminar dependencias parciales trasladando los atributos que dependen únicamente de una parte de la clave compuesta a tablas independientes.

**Tabla CLIENTE**

<img width="457" height="163" alt="image" src="https://github.com/user-attachments/assets/a2749c48-9816-452f-8887-da2ccff819e0" />

**Tabla METODO_DE_PAGO**

ID_METODO (PK)	DESCRIPCION

<img width="305" height="163" alt="image" src="https://github.com/user-attachments/assets/4586824f-aa40-4875-8fcb-810dc14ac584" />

**Tabla ALMACEN**

<img width="457" height="121" alt="image" src="https://github.com/user-attachments/assets/ae655051-31a2-4be9-b435-beb3ae50fa6a" />

**Tabla PRODUCTO**

<img width="1412" height="201" alt="image" src="https://github.com/user-attachments/assets/376810a4-926a-42c2-a639-8236d9d26c31" />

**Tabla VENTA**

<img width="683" height="163" alt="image" src="https://github.com/user-attachments/assets/3ec3bd10-12e4-4268-b45a-02e25128010c" />

**Tabla DETALLE_VENTA**

<img width="835" height="201" alt="image" src="https://github.com/user-attachments/assets/d4d03f1a-94cf-45e6-967c-68fd5f7c7d23" />

**Regla aplicada:** Estar en 2FN y eliminar dependencias transitivas, desacoplando los atributos no clave dependientes de otros atributos no clave en tablas maestras independientes (CLIENTE, METODO_DE_PAGO, ALMACEN) y vinculándolas mediante claves foráneas (FK).

**📌 Justificación Técnica de Desnormalización**
La presencia del campo PRECIO_UNITARIO en la entidad DETALLE_VENTA responde a un criterio de desnormalización consciente para el mantenimiento de datos históricos. Almacenar este valor en el detalle evita la pérdida o alteración de montos en transacciones pasadas en caso de que el PRECIO_VENTA sufra modificaciones futuras en el catálogo de la tabla PRODUCTO.

**📌 Otros Atributos Derivados Conservados**
SUBTOTAL (CANTIDAD × PRECIO_UNITARIO) en DETALLE_VENTA y MONTO_TOTAL (suma de subtotales) en VENTA son atributos calculables, por lo que técnicamente son redundantes. Se conservan de forma consciente para agilizar el reporte de cierre del día (total vendido, efectivo vs QR) y se mantienen consistentes al momento de registrar cada venta.

**📌 Clave de DETALLE_VENTA**
En 1FN la clave era compuesta (ID_VENTA, ID_PRODUCTO). En el modelo final se usa ID_DETALLE como clave primaria sustituta y se conserva la restricción UNIQUE (ID_VENTA, ID_PRODUCTO), de modo que un producto no se repita en la misma venta. Las dependencias funcionales de la 2FN no cambian.


