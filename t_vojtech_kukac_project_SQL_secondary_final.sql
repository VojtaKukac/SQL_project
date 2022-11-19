CREATE OR REPLACE TABLE t_vojtech_kukac_project_SQL_secondary_final AS 
SELECT 
		cn.continent,
		cn.country, 
		eco.year, 
		eco.GDP,
		eco.gini, 
		eco.population 
FROM countries AS cn
JOIN economies AS eco
	ON cn.country = eco.country
WHERE 
	LOWER (cn.continent) = 'europe' AND 
	eco.GDP IS NOT NULL
ORDER BY cn.country, eco.year;

