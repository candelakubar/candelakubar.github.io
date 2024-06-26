-- REMOVEMOS DUPLICADOS 
SELECT *
INTO dataclean_staging
FROM dataclean
WHERE 1 = 1;




SELECT *,
       ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, percentage_laid_off,'date', stage, country, funds_raised_millions ORDER BY (SELECT NULL) )
	   AS row_num
FROM dataclean_staging


SELECT*FROM dataclean_staging

-- Borramos los duplicados 

WITH duplicate_cte AS
(
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY company, industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions ORDER BY (SELECT NULL)) AS row_num
    FROM dataclean_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1


-- ESTANDARIZAMOS LA INFORMACION
--Eliminamos los espacios innecesarios

SELECT DISTINCT company, TRIM(company) FROM dataclean_staging

UPDATE dataclean_staging
SET company=TRIM(company)

SELECT DISTINCT industry FROM dataclean_staging

ORDER BY industry

-- Noto que hay tres tipos de industrias que son las mismas 
-- Crypto, Crypto Currency y Cryptocurrency. Las unifico

UPDATE dataclean_staging
SET industry= 'Crypto'
WHERE industry LIKE 'Crypto%'

SELECT DISTINCT industry FROM dataclean_staging
ORDER BY industry


-- Modifico las locaciones con errores 
SELECT DISTINCT location FROM dataclean_staging
ORDER BY location 

UPDATE dataclean_staging
SET location= 'Düsseldorf'
WHERE location= 'DÃ¼sseldorf'


UPDATE dataclean_staging
SET location= 'Düsseldorf'
WHERE location= 'Dusseldorf'

UPDATE dataclean_staging
SET location= 'Florianapolis'
WHERE location= 'FlorianÃ³polis'


UPDATE dataclean_staging
SET location= 'Malmo'
WHERE location= 'MalmÃ¶'

SELECT DISTINCT country FROM dataclean_staging
ORDER BY country



UPDATE dataclean_staging
SET country= 'United States'
WHERE country= 'United States.'

-- Ahora modifico el foramto de la columna date

ALTER TABLE dataclean_staging
ALTER COLUMN date DATE;

UPDATE dataclean_staging
SET date= CONVERT(DATE, date, 103)
EXEC sp_help 'dataclean_staging';



-- BLACK VALUES
-- VAMOS A VER AHORA LOS VALORES NULOS DE LA TABLA total_laid_off

SELECT*FROM dataclean_staging

WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL

SELECT * FROM dataclean_staging
WHERE industry IS NULL 
or industry =' ' 


SELECT * FROM dataclean_staging
WHERE company ='Airbnb' 

UPDATE dataclean_staging
SET industry = 'Travel'
WHERE company = 'Airbnb';


SELECT * FROM dataclean_staging
WHERE company ='Carvana' 

UPDATE dataclean_staging
SET industry = 'Transportation'
WHERE company = 'Carvana';


SELECT * FROM dataclean_staging
WHERE company ='Juul' 

UPDATE dataclean_staging
SET industry = 'Consumer'
WHERE company = 'Juul';




-- REMOVEMOS FILAS / COLUMNAS INNECESARIAS


SELECT*FROM dataclean_staging

WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL


DELETE FROM dataclean_staging
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;



