
--Creo un procedimiento para no reescribir varias veces lo mismo blabla 

DROP PROCEDURE IF EXISTS limp;
GO

CREATE PROCEDURE limp
AS
BEGIN
    SELECT * FROM limpieza;
END;



-- reescribo la primer columna, el resto estan ok 


USE clean;
SELECT * FROM limpieza


EXEC sp_rename 'limpieza.[Id?empleado]', 'Id_emp' , 'COLUMN';



EXEC limp


-- cuento la cantidad de duplicados existentes

SELECT Id_emp, COUNT(*) AS cant_duplicados
FROM limpieza
GROUP BY Id_emp
HAVING COUNT(*) > 1;

-- Creo una subquery para poder saber la cantidad total de duplicados 

SELECT COUNT(*) as cat_duplicados_total
FROM (SELECT Id_emp, COUNT(*) AS cant_duplicados
FROM limpieza
GROUP BY Id_emp
HAVING COUNT(*) > 1) as subquery

--Para eliminarlos creo una tabla temporal con valores únicos y luego la defino como permanente.

EXEC sp_rename 'limpieza', 'conduplicados';


SELECT DISTINCT *
INTO #temp_limpieza
FROM conduplicados;


SELECT* FROM #temp_limpieza

SELECT * INTO limpieza FROM #temp_limpieza;


SELECT* FROM limpieza


EXEC limp


DROP TABLE conduplicados



EXEC sp_rename 'limpieza.[Apellido]', 'Last_name' , 'COLUMN';


EXEC sp_rename 'limpieza.[star_date]', 'start_date' , 'COLUMN';


EXEC sp_rename 'limpieza.[género]', 'gender' , 'COLUMN';


-- Una vez que tenemos nuestra tabla sin duplicados, vemos las propiedades de la misma

EXEC sp_help 'limpieza';
-- modifico el type de type: como no me permite cambiar el tipo de manera directa, creo una columna temporal de 'type', elimino la original
--y cambio el nombre de la nueva por la original. 

ALTER TABLE limpieza
ADD type_temp VARCHAR(MAX);


UPDATE limpieza
SET type_temp = CAST(type AS VARCHAR(MAX));

ALTER TABLE limpieza
DROP COLUMN type;

EXEC sp_rename 'limpieza.type_temp', 'type', 'COLUMN';



-- Ahora si, cambio los números por palabras: 

SELECT
    CASE 
        WHEN type = 1 THEN 'Remote'
        WHEN type = 0 THEN 'Hybrid' 
        ELSE 'Other'
    END as ejemplo
FROM limpieza;



 UPDATE limpieza
SET type =CASE 
        WHEN type = 1 THEN 'Remote'
        WHEN type = 0 THEN 'Hybrid' 
        ELSE 'Other'
    END;

EXEC limp

-- Ahora vamos a ver la primer columna, 'name' y eliminamos los espacios que contengan 
SELECT name FROM limpieza
WHERE len(name)-len(trim(name))>0


-- Por precaucion, primero probamos nuestro código con un select
SELECT name, TRIM(name) as name
FROM limpieza
GROUP BY name


-- Una vez que me aseguro de que funciona, ahora si modifico la tabla

UPDATE limpieza
SET Name = TRIM(Name);


SELECT Last_name, TRIM(Last_name) as Last_name
FROM limpieza
WHERE len(Last_name)-len(trim(Last_name))>0
GROUP BY Last_name

 UPDATE limpieza
SET Last_name = TRIM(Last_name);

EXEC limp


SELECT area, TRIM(area) as area
FROM limpieza
WHERE len(area)-len(trim(area))>0
GROUP BY area

-- Vemos que en área no hay que modificar nada


-- Vamos a en la columna género, el idioma
SELECT    
	CASE 
        WHEN gender = 'hombre' THEN 'male'
		WHEN gender = 'mujer' THEN 'female'
        ELSE gender
    END AS genero
FROM limpieza;



 UPDATE limpieza
SET gender =CASE 
        WHEN gender = 'hombre' THEN 'male'
		WHEN gender = 'mujer' THEN 'female'
        ELSE gender
		END;

EXEC limp


-- En la columna de salary, hacemos lo mismo  que en name, eliminamos los espacios en blanco
SELECT birth_date,
    CASE 
        WHEN birth_date LIKE '%/%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        WHEN birth_date LIKE '%-%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        ELSE NULL
    END AS new_birth_date
FROM limpieza;

UPDATE limpieza
SET birth_date =CASE 
WHEN birth_date LIKE '%/%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        WHEN birth_date LIKE '%-%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        ELSE NULL
    END;

	UPDATE limpieza
SET birth_date =CASE 
WHEN birth_date LIKE '%/%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        WHEN birth_date LIKE '%-%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        ELSE NULL
    END;

ALTER TABLE limpieza
ALTER COLUMN birth_date DATE;

EXEC sp_help 'limpieza';

-- Hacemos lo mismo pero con la columna start_date
-- Aqui tuve que volver a ingresar los datos de la columna por un 
-- error al eliminar los datos
SELECT*FROM limpieza

SELECT star_date FROM date


ALTER TABLE limpieza
ADD start_date DATE;

UPDATE limpieza
SET start_date = CAST([star_date] AS DATE)
FROM date;




SELECT finish_date,
    CASE 
        WHEN finish_date LIKE '%/%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        WHEN finish_date LIKE '%-%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        ELSE NULL
    END AS new_finish_date
FROM limpieza;

UPDATE limpieza
SET finish_date =CASE 
WHEN finish_date LIKE '%/%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        WHEN finish_date LIKE '%-%' THEN CONVERT(VARCHAR(10), TRY_CONVERT(DATE, birth_date, 101), 120)
        ELSE NULL
    END;

ALTER TABLE limpieza
ALTER COLUMN finish_date DATE;

EXEC limp

-- CÁLCULO DE LA EDAD DE LOS EMPLEADOS

ALTER TABLE limpieza
ADD Age INT;

SELECT 
    name,
    birth_date,
    start_date,
    DATEDIFF(year, birth_date, start_date) - 
    CASE 
        WHEN DATEADD(year, DATEDIFF(year, birth_date, start_date), birth_date) > start_date THEN 1 
        ELSE 0 
    END AS edad_de_ingreso
FROM 
    limpieza;

UPDATE limpieza
SET AGE = DATEDIFF(year, birth_date, GETDATE())


-- A modo de ejemplo, vamos a crear un mail para cada empleado, 
-- compuesto por 'nombre_apellido@gmail.com'
EXEC limp

DROP TABLE Mail


ALTER TABLE limpieza
ADD Mail VARCHAR;

ALTER TABLE limpieza
ALTER COLUMN Mail VARCHAR(255); -- O el tamaño que consideres necesario


UPDATE limpieza
SET Mail= CONCAT(name, '_', LEFT(Last_name, 2),'.',LEFT(type,1),'@gmail.com') 


SELECT Id_emp, Name, Last_name, age,gender, area, salary, mail, finish_date FROM limpieza



SELECT area ,count(*) as cantidad_empleados FROM limpieza

GROUP BY area

ORDER BY cantidad_empleados DESC

