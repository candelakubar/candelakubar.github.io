SELECT*FROM wine
ORDER BY ID

EXEC sp_rename 'wine.F1', 'ID', 'COLUMN';


ALTER TABLE wine
DROP COLUMN F12;



-- Siguiendo el orden de las columnas, analizo las columnas que considero con relevancia para el análisis posterior 

SELECT DISTINCT country, count(COUNTRY) AS cantidad FROM wine
GROUP BY country
ORDER BY count(COUNTRY)

--Los países estan bien escritos, contamos con 43 de ellos. Contamos con un nulo que no posee ninguna informacion relevante. Procedo a eliminarlo 


SELECT*FROM wine

WHERE  description='Old Vine';


DELETE FROM wine
WHERE description = 'Old Vine';

-- La columna 'description' no es de relevancia, la voy a dejar por momento para detectar filas duplicadas.
--Veo los nulos de 'designation', 'region_1', 'region_2'


SELECT ISNULL(designation, 'NULL') AS designation, COUNT(*) AS cantidad 
FROM wine
GROUP BY designation
ORDER BY COUNT(*) DESC;

SELECT ISNULL(region_1, 'NULL') AS region_1, COUNT(*) AS cantidad 
FROM wine
GROUP BY region_1
ORDER BY COUNT(*) DESC;

SELECT ISNULL(region_2, 'NULL') AS region_2, COUNT(*) AS cantidad 
FROM wine
GROUP BY region_2
ORDER BY COUNT(*) DESC;

-- Calculo el porcentaje de nulos que contiene la tabla en la columna 'designation'

SELECT 
    SUM(CASE WHEN designation IS NULL THEN 1 ELSE 0 END) AS nulos_designation,
	SUM(CASE WHEN region_1 IS NULL THEN 1 ELSE 0 END) AS nulos_r1,
	SUM(CASE WHEN region_2 IS NULL THEN 1 ELSE 0 END) AS nulos_r2,

    COUNT(*) AS total_filas,
   CAST(ROUND (100.0 * SUM(CASE WHEN designation IS NULL THEN 1 ELSE 0 END) / COUNT(*),2) AS DECIMAL (10,2)) AS porcentaje_nulos,
   CAST(ROUND (100.0 * SUM(CASE WHEN region_1 IS NULL THEN 1 ELSE 0 END) / COUNT(*),2) AS DECIMAL (10,2)) AS porcentaje_nulos_r1,
   CAST(ROUND (100.0 * SUM(CASE WHEN region_2 IS NULL THEN 1 ELSE 0 END) / COUNT(*),2) AS DECIMAL (10,2)) AS porcentaje_nulos_r2
FROM wine;


-- Para 'designation' , son unos 48.744 filas nulas, correspondiendo a un casi 30% de la base de datos total . 
-- Para 'region_1' , son unos 7471 filas nulas, correspondiendo a un 15% de la base de datos total . 
-- Para 'region_2' , son unos 28773 filas nulas, correspondiendo a un 59% de la base de datos total . 

-- Vamos a  reemplaza el dato faltante como 'desconocido'

SELECT
    CASE 
        WHEN designation IS NULL THEN 'Desconocido'
        ELSE designation
    END as ejemplo
FROM wine;

-- Comprobando que la consulta funciona como necesito, ahora sí modifico los datos.

UPDATE wine
SET designation=CASE 
        WHEN designation IS NULL THEN 'Desconocido'
        ELSE designation
    END 

UPDATE wine
SET region_1=CASE 
        WHEN region_1 IS NULL THEN 'Desconocido'
        ELSE region_1
    END

UPDATE wine
SET region_2 =CASE 
        WHEN region_2 IS NULL THEN 'Desconocido'
        ELSE region_2
    END 

-- Sigo con 'province' 
SELECT DISTINCT province, country FROM wine
ORDER BY province

--No me figuran datos nulos ni nada a modificar


-- 'Variety'

SELECT DISTINCT variety FROM wine
ORDER BY variety

--'Winnery'

SELECT DISTINCT winery FROM wine
ORDER BY winery






-- Continuando con los valores nulos, analizo los nulos de todas mis columnas 

SELECT
    SUM(CASE WHEN ID IS NULL THEN 1 ELSE 0 END) AS nulos_en_F1,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS nulos_en_country,
    SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS nulos_en_description,
    SUM(CASE WHEN designation IS NULL THEN 1 ELSE 0 END) AS nulos_en_designation,
    SUM(CASE WHEN points IS NULL THEN 1 ELSE 0 END) AS nulos_en_points,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS nulos_en_price,
    SUM(CASE WHEN province IS NULL THEN 1 ELSE 0 END) AS nulos_en_province,
    SUM(CASE WHEN region_1 IS NULL THEN 1 ELSE 0 END) AS nulos_en_region_1,
    SUM(CASE WHEN region_2 IS NULL THEN 1 ELSE 0 END) AS nulos_en_region_2,
    SUM(CASE WHEN variety IS NULL THEN 1 ELSE 0 END) AS nulos_en_variety,
    SUM(CASE WHEN winery IS NULL THEN 1 ELSE 0 END) AS nulos_en_winery
FROM wine;



-- Debido a que las columnas 'country', 'province' O 'variety'  las considero relevantes para mi análisis,
-- Consulto  todas las filas con valores nulos en 'country', 'province' O 'variety' 

SELECT *
FROM wine
WHERE country IS NULL OR province IS NULL OR variety IS NULL;


-- Las elimino 


DELETE FROM wine
WHERE  country IS NULL OR province IS NULL OR variety IS NULL;




-- Elimino las filas que están duplicadas , considerando las mismas aquellas que tienen exactamente la misma descripción


SELECT description, COUNT(description) AS cantidad
FROM wine
GROUP BY description
HAVING COUNT(description) > 1
ORDER BY cantidad DESC;


DELETE FROM wine
WHERE description IN (
    SELECT description
    FROM wine
    GROUP BY description
    HAVING COUNT(description) > 1
);


SELECT *
FROM wine
WHERE price IS NULL

-- COLUMNA 'PRICE' 
-- Calculo el porcentaje de nulos que contiene la tabla en la columna 'price'

SELECT 
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS cantidad_nulos,
    COUNT(*) AS total_filas,
   CAST(ROUND (100.0 * SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) / COUNT(*),2) AS DECIMAL (10,2)) AS porcentaje_nulos
FROM wine;


-- Como resultado, obtengo que tengo un 9.42% de valores nulos.


--Como ese porcentaje me parece relevante, puedo plantear la idea de reemplazar los valores nulos por unos aproximados, considerando las columnas 'points' y 'countrys'  
--Para reemplazar los valores nulos en la columna 'price' usando las características 'points' y 'country' para predecir los valores faltantes, podrías utilizar un modelo 
--de regresión lineal o cualquier otro modelo de aprendizaje automático para predecir el precio en función de las características disponibles.
--Sin embargo, esto requeriría un análisis más detallado de mis datos y la implementación de un modelo de machine learning.
--Es por eso que proporciono un enfoque simplificado utilizando SQL para reemplazar los valores nulos en la columna 'price' con el promedio del precio para cada 
--combinación única de 'points'y 'country':

ALTER TABLE wine ALTER COLUMN price FLOAT


EXEC sp_help 'wine';

UPDATE wine
SET price = CASE 
                WHEN price = 0 THEN ISNULL(avg_prices.avg_price, 0)
                ELSE price
            END
FROM wine
LEFT JOIN (
    SELECT country, points, AVG(price) AS avg_price
    FROM wine
    WHERE price != 0  -- Excluimos los valores iguales a cero del cálculo del promedio
    GROUP BY country, points
) AS avg_prices
ON wine.country = avg_prices.country
AND wine.points = avg_prices.points
WHERE wine.price = 0; 


--En esta consulta, utilizamos una expresión CASE para verificar si el valor en la columna 'price' es igual a cero. Si lo es, 
--utilizamos la función ISNULL para reemplazarlo por el promedio de 'price' para el mismo 'country' o 'points', o cero si no hay valores para calcular el promedio.
--Si el valor no es igual a cero, lo dejamos sin cambios.
 


 -- Por último, elimino la columna description 

 
ALTER TABLE wine
DROP COLUMN description



SELECT*FROM wine