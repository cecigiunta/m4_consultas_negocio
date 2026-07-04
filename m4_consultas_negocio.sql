USE Ventas_Tech_DB;

/* Consulta 1: Resumen ejecutivo mensual Total facturado, 
1. cantidad de pedidos COUNT y 
2. ticket promedio AVG, 
3. agrupados por mes GROUP BY. 
4. Calculá el total como cantidad * precio_unitario. 
Usá alias descriptivos en español y agrupá por mes con EXTRACT(MONTH FROM fecha_venta). */
SELECT
    MONTH (fecha_venta) AS mes,-- Extraemos el número de mes de la fecha de venta
	SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM dbo.ventas

GROUP BY MONTH (fecha_venta);


/* Consulta 2: Ranking de productos Top 5 de id_producto por total facturado, 
mostrando las unidades vendidas (SUM(cantidad)) y el total generado. 
Usá GROUP BY id_producto, ORDER BY y limitá el resultado a 5. */
SELECT TOP 5  -- Seleccionamos únicamente los 5 productos con mayor facturación
    id_producto,
    SUM(cantidad) AS unidades_vendidas, -- sumamos la cantidad vendida de cada producto
    SUM(cantidad * precio_unitario) AS total_facturado 
	   -- Calculamos el total facturado por producto. Multiplicando la cantidad vendida por el precio unitario
	   -- y sumando todas las ventas de ese producto
FROM dbo.ventas
GROUP BY id_producto -- Agrupamos los registros por producto para que las funciones SUM() se hagan para c/u
ORDER BY total_facturado DESC; -- Ordenamos desde el mayor total facturado al menor


/*Consulta 3: Clientes recurrentes id_cliente que hayan realizado más de un pedido, 
mostrando la cantidad de pedidos y el total gastado. 
Usá GROUP BY id_cliente y HAVING COUNT(*) > 1. */
SELECT id_cliente,
	COUNT(*) AS cantidad_pedidos, -- Contamos la cantidad de pedidos para c/cliente.
	SUM (cantidad * precio_unitario) AS total_gastado -- Calculamos el total gastado de c/cliente sumando cantidad × precio unitario
FROM dbo.ventas

GROUP BY id_cliente --Agrupamos por cliente p que se calcule todo para cada uno
HAVING COUNT(*) > 1; -- Filtramos los grupos para mostrar solo clientes con más de un pedido (recurrentes)


/* Consulta 4: Meses por encima/por debajo del promedio Total facturado por mes, 
con una columna adicional que etiquete con CASE WHEN si ese mes quedó 'Por encima' o 
'Por debajo' del promedio mensual general.  */
-- Este ejercicio se resuelve utilizando SUBCONSULTAS.

SELECT
    mes,
    total_facturado, --Lo definimos dentro de la consultas hecha en el WHEN..

    CASE -- Comparamos el total facturado del mes con el promedio mensual general para clasificar "Por encima"/"Por debajo"
        WHEN total_facturado > --Si el total facturado es mayor al promedio mensual general = "Por encima"
            (
                SELECT AVG(total_facturado)  -- Calculamos el promedio de los totales facturados por mes
                FROM (
                        SELECT -- Consulta para obtener el total facturado de cada mes
                            SUM(cantidad * precio_unitario) AS total_facturado 
                        FROM dbo.ventas
                        GROUP BY MONTH(fecha_venta)
                     ) AS promedio
            )
        THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion
FROM
(
    SELECT
        MONTH(fecha_venta) AS mes, -- Extraemos el número de mes de la fecha de venta
        SUM(cantidad * precio_unitario) AS total_facturado -- Calculamos el total facturado del mes multiplicando cantidad * precio unitario
    FROM dbo.ventas
    GROUP BY MONTH(fecha_venta) -- Agrupamos las ventas por mes para obtener un total por cada uno
) AS ventas_por_mes;	



