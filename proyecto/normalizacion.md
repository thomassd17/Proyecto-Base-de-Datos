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
