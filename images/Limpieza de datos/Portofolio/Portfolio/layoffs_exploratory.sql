
SELECT* FROM dataclean

-- Máxima y mímina cantidad de despidos totales

SELECT MIN(CONVERT(float, total_laid_off)) AS min_total_laid_off, MAX(CONVERT(float, total_laid_off)) AS  max_total_laid_off
FROM dataclean;




--Fecha mas lejana y más actual 
SELECT MIN(CONVERT(DATE, [date], 101)), MAX(CONVERT(DATE, [date], 101))
FROM dataclean;



-- Cantidad de despidos por compañía
SELECT company, SUM(total_laid_off) as 'SUMA total_laid_off'
FROM dataclean
group by company
ORDER BY 2 DESC


-- Cantidad de despidos por industria
SELECT industry, SUM(total_laid_off) as 'SUMA total_laid_off'
FROM dataclean
group by industry
ORDER BY 2 DESC

-- Cantidad de despidos por país
SELECT country, SUM(total_laid_off) as 'SUMA total_laid_off'
FROM dataclean
group by country
ORDER BY 2 DESC

-- Cantidad de despidos por año

SELECT YEAR(date), SUM(total_laid_off) as 'SUMA total_laid_off'
FROM dataclean
group by YEAR(date)
ORDER BY 1 DESC

-- Cantidad de despidos por stage

SELECT stage, SUM(total_laid_off) as 'SUMA total_laid_off'
FROM dataclean
group by stage
ORDER BY 2 DESC



SELECT FORMAT(date, 'yyyy-MM') AS fecha , SUM(total_laid_off) AS 'SUMA total_laid_off'
FROM dataclean
WHERE FORMAT(date, 'yyyy-MM') IS NOT NULL
GROUP BY FORMAT(date, 'yyyy-MM')
ORDER BY 1 ASC

-- Sumatoria de despidos mes a mes

WITH Rolling_Total AS (
    SELECT FORMAT(date, 'yyyy-MM') AS fecha,
           SUM(total_laid_off) AS 'SUMA total_laid_off'
    FROM dataclean
    WHERE FORMAT(date, 'yyyy-MM') IS NOT NULL
    GROUP BY FORMAT(date, 'yyyy-MM')
)
SELECT fecha, SUM([SUMA total_laid_off]) OVER (ORDER BY fecha) AS rolling_total
FROM Rolling_Total
 

WITH Rolling_Total AS (
    SELECT FORMAT(date, 'yyyy-MM') AS fecha,
           SUM(total_laid_off) AS 'SUMA total_laid_off'
    FROM dataclean
    WHERE FORMAT(date, 'yyyy-MM') IS NOT NULL
    GROUP BY FORMAT(date, 'yyyy-MM')
)

-- Año y cantidad de despidos por compañía
SELECT company, year(date) AS 'Year' , SUM(total_laid_off) as 'SUMA total_laid_off'
FROM dataclean
group by company,year(date)
ORDER BY 3 DESC

-- Realizo un ranking de las compañías que más despidieron , a partir de una tabla temporal  (CTE)

WITH company_year AS (
    SELECT company,
           YEAR(date) AS [Year],
           SUM(total_laid_off) AS [SUMA total_laid_off]
    FROM dataclean
    GROUP BY company, YEAR(date)
)
SELECT *,
       DENSE_RANK() OVER (PARTITION BY [Year] ORDER BY [SUMA total_laid_off] DESC) AS Ranking
FROM company_year
WHERE [Year] IS NOT NULL
ORDER BY Ranking;


-- Agrego a la consulta ese ultimo select para volver a filtrar dentro de esa tabla 
-- Hago un top 5

WITH company_year AS (
    SELECT company,
           YEAR(date) AS [Year],
           SUM(total_laid_off) AS [SUMA total_laid_off]
    FROM dataclean
    GROUP BY company, YEAR(date)
), company_year_ranking AS
(
SELECT *,
       DENSE_RANK() OVER (PARTITION BY [Year] ORDER BY [SUMA total_laid_off] DESC) AS Ranking
FROM company_year
WHERE [Year] IS NOT NULL
)
SELECT*FROM company_year_ranking
WHERE ranking<=5
ORDER BY Ranking
