# 📐 Proceso de Normalización — Tienda "Natalia"

Este documento detalla el análisis y proceso de normalización aplicado a la base de datos de la Tienda "Natalia", pasando por la Forma No Normalizada (0FN) hasta la Tercera Forma Normal (3FN) para eliminar redundancias y anomalías de actualización.

0FN (Forma No Normalizada)
Estado inicial correspondiente al registro manual en cuaderno borrador. Los productos vendidos en una misma transacción se encuentran agrupados en una sola celda como un atributo multivaluado.

<img width="652" height="163" alt="image" src="https://github.com/user-attachments/assets/f2e0d622-a02f-4d33-a6a0-5107d9579b96" />

1FN (Primera Forma Normal)
 |Regla: Se eliminan los grupos repetitivos garantizando valores atómicos por celda y se define una clave primaria compuesta (ID_VENTA, ID_PRODUCTO).

<img width="834" height="177" alt="image" src="https://github.com/user-attachments/assets/32108de9-cff2-496b-967a-f485d032e0b2" />

2FN (Segunda Forma Normal)
|Regla: Estar en 1FN y eliminar dependencias parciales. Todos los atributos no clave deben depender de la totalidad de la clave primaria (ID_VENTA, ID_PRODUCTO).

Dependencias Funcionales Evaluadas:
1.ID_VENTA -> FECHA_HORA, CLIENTE, METODO_PAGO, MONTO_TOTAL
2.ID_PRODUCTO -> NOMBRE_PRODUCTO, ALMACEN
3.(ID_VENTA, ID_PRODUCTO) -> CANTIDAD, PRECIO_UNITARIO, SUBTOTAL

Estructura Tabular en 2FN:
Tabla VENTA_2FN

<img width="596" height="163" alt="image" src="https://github.com/user-attachments/assets/f625fe71-4551-4fde-9b19-1f0113e06d45" />

Tabla PRODUCTO_2FN

<img width="715" height="177" alt="image" src="https://github.com/user-attachments/assets/a1aa5712-5332-4846-a1ef-6a72d3f36ca6" />

Tabla DETALLE_VENTA_2FN

<img width="715" height="254" alt="image" src="https://github.com/user-attachments/assets/2e864dbe-f11b-46c3-bb15-51602cf725b3" />

3FN (Tercera Forma Normal)
|Regla: Estar en 2FN y eliminar dependencias transitivas entre atributos no clave.

Eliminación de Transitividades:
|En VENTA_2FN: ID_VENTA -> CLIENTE y ID_VENTA -> METODO_PAGO. Se desacoplan las entidades CLIENTE y METODO_DE_PAGO.
|En PRODUCTO_2FN: ID_PRODUCTO -> ALMACEN. Se desacopla la entidad ALMACEN.

Esquema Logico Normalizado 3FN

[ CLIENTE ] (ID_CLIENTE [PK], NOMBRE)
     │
     └──(1:N)──> [ VENTA ] (ID_VENTA [PK], FECHA_HORA, MONTO_TOTAL, ID_CLIENTE [FK], ID_METODO [FK])
                     │                                                      ▲
                     │                                                      │
[ METODO_DE_PAGO ] ──┘(1:N)                                                │
                                                                            │
[ DETALLE_VENTA ] (ID_DETALLE [PK], ID_VENTA [FK], ID_PRODUCTO [FK], CANTIDAD, PRECIO_UNITARIO, SUBTOTAL)
     ▲
     │
     └──(1:N)── [ PRODUCTO ] (ID_PRODUCTO [PK], NOMBRE, MARCA, CATEGORIA, PRECIO_VENTA, PRECIO_COMPRA, STOCK_ESTANTE, STOCK_ALMACEN, STOCK_MIN, ID_ALMACEN [FK])
                     ▲
                     │
[ ALMACEN ] ─────────┘(1:N) (ID_ALMACEN [PK], NOMBRE_ALMACEN)


📌 Justificación Técnica de Desnormalización
La presencia del campo PRECIO_UNITARIO en la entidad DETALLE_VENTA responde a un criterio de desnormalización consciente para el mantenimiento de datos históricos. Almacenar este valor en el detalle evita la pérdida o alteración de montos en transacciones pasadas en caso de que el PRECIO_VENTA sufra modificaciones futuras en el catálogo de la tabla PRODUCTO.
