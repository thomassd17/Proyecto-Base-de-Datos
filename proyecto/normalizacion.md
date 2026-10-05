# 📐 Proceso de Normalización — Tienda "Natalia"

Este documento detalla el análisis y proceso de normalización aplicado a la base de datos de la Tienda "Natalia", pasando por la Forma No Normalizada (0FN) hasta la Tercera Forma Normal (3FN) para eliminar redundancias y anomalías de actualización.

0FN (Forma No Normalizada)
Estado inicial correspondiente al registro manual en cuaderno borrador. Los productos vendidos en una misma transacción se encuentran agrupados en una sola celda como un atributo multivaluado.

ID_VENTA	FECHA_HORA	CLIENTE	METODO_PAGO	PRODUCTO	ALMACEN	TOTAL
V001	10/4/2026 10:30	Juan Perez	Efectivo	"Cuaderno 2u 15bs
Boligrafos 5u 2bs"	Repisa	40bs
V002	10/4/2026 10:40	Maria Añez	QR	Borrados 1u 3bs	Repisa	3bs
<img width="652" height="163" alt="image" src="https://github.com/user-attachments/assets/f2e0d622-a02f-4d33-a6a0-5107d9579b96" />



