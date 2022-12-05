-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE VIEW v_select_cz_payllor AS 
SELECT 
	year_price,
	industry_branch,
	pay_value
FROM 
	t_vojtech_kukac_project_SQL_primary_final
GROUP BY 
	year_price,
	industry_branch
ORDER BY 
	industry_branch,
	year_price;
	
CREATE OR REPLACE VIEW v_select_cz_payllor_growth AS
SELECT 
	year_price,
	industry_branch,
	pay_value,
	LEAD (pay_value,1) OVER (PARTITION BY industry_branch ORDER BY industry_branch, year_price) next_pay_value,
	ROUND ((((LEAD (pay_value,1) OVER (PARTITION BY industry_branch ORDER BY industry_branch, year_price)) - pay_value) / pay_value) * 100,2) AS growth
FROM
	v_select_cz_payllor
ORDER BY industry_branch,year_price;

SELECT
	industry_branch,
	ROUND(AVG(growth),2) AS pay_growth
FROM v_select_cz_payllor_growth
WHERE growth IS NOT NULL
GROUP BY industry_branch;

-- Ve sloupci "Pay_growth" je možné vidět, že celkově ve všech odvětvích mzda v průběhu let roste.

-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

CREATE OR REPLACE VIEW v_select_year_category AS
SELECT
	AVG(price) AS avg_price,
	AVG(pay_value) AS avg_pay,
	category,
	quantity,
	unit,
	year_price
FROM 
	t_vojtech_kukac_project_SQL_primary_final
WHERE 
	year_price IN (2006,2018) AND 
	category IN ("Chléb konzumní kmínový","Mléko polotučné pasterované")
GROUP BY 
	year_price, category;
	
SELECT 
	avg_price,
	avg_pay,
 	category,
 	year_price,
	ROUND(avg_pay / avg_price,2) AS quantity_goods,
	unit
FROM 
	v_select_year_category;

-- V roce 2006 si za průměrnou mzdu bylo možné koupit 1 287,16 kg chleba nebo 1 437,46 litrů mléka.
-- V roce 2018 si za průměrnou mzdu bylo možné koupit 1 342,32 kg chleba nebo 1 641,77 litrů mléka.

-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

CREATE OR REPLACE VIEW v_cz_price_difference AS
SELECT 
	year_price,
	category,
	price,
	LEAD (price,1) OVER (PARTITION BY category ORDER BY category, year_price) next_year_price,
	ROUND ((((LEAD (price,1) OVER (PARTITION BY category  ORDER BY category, year_price)) - price) / price) * 100,2) difference
FROM 
	t_vojtech_kukac_project_sql_primary_final
GROUP BY 
	category, year_price;
			
SELECT 
	category,  
	ROUND(AVG (difference),2)
FROM 
	v_cz_price_difference
GROUP BY
	category
ORDER BY 
	AVG (difference);

-- Z dat je možné vypozorovat, že nejpomaleji zdražující kategorie potravin je kategorie Cukr krystal.

-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

CREATE OR REPLACE VIEW v_cz_price_growth AS
SELECT 
	year_price, 
	ROUND(AVG(difference),2) AS difference 
FROM v_cz_price_difference 
GROUP BY year_price;

CREATE OR REPLACE VIEW v_cz_payllor_growth AS
SELECT 
	year_price, 
	ROUND(AVG(growth),2) AS growth 
FROM v_select_cz_payllor_growth 
GROUP BY year_price;

SELECT 
	v_cz_p.year_price,
	v_cz_p.difference AS price_growth,
	v_cz_pay.growth AS pay_growth,
	v_cz_p.difference - v_cz_pay.growth AS difference_price_pay
FROM 
	v_cz_price_growth AS v_cz_p
LEFT JOIN v_cz_payllor_growth AS v_cz_pay
	ON v_cz_p.year_price = v_cz_pay.year_price
ORDER BY difference_price_pay;

-- V žádném roce nebyl nárůst cen potravit vyšší než 10%. 
-- V roce 2012 byl nejvyšší nárůst cen oporit nárůstu mezd a to bylo 9,22%.

-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

CREATE OR REPLACE VIEW v_gdp_growth AS
SELECT 
	*,
	LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, year) next_year_GDP,
	ROUND((((LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, year))-GDP) / GDP ) * 100,2) GDP_growth
FROM 
	t_vojtech_kukac_project_SQL_secondary_final
WHERE 
	country = LOWER("czech republic");


CREATE OR REPLACE VIEW v_cz_price_growth AS
SELECT 
	year_price, 
	ROUND(AVG(difference),2) AS difference 
FROM 
	v_cz_price_difference 
GROUP BY 
	year_price;

CREATE OR REPLACE VIEW v_cz_payllor_growth AS
SELECT 
	year_price, 
	ROUND(AVG(growth),2) AS growth 
FROM 
	v_select_cz_payllor_growth 
GROUP BY 
	year_price;

SELECT 
	v_gdp.year AS basic_year,
	v_gdp.year + 1 AS next_year,
	v_gdp.GDP_growth,
	v_cz_p.difference AS price_growth,
	v_cz_pay.growth AS pay_growth
FROM 
	v_gdp_growth AS v_gdp
LEFT JOIN v_cz_price_growth AS v_cz_p
	ON v_gdp.`year`= v_cz_p.year_price
LEFT JOIN v_cz_payllor_growth AS v_cz_pay
	ON v_gdp.`year`= v_cz_pay.year_price
WHERE v_gdp.year >= 2006 AND v_gdp.year <= 2017 ;

-- Z dat vyplývá, že výška HDP nemá přímý vliv na růst mezd nebo cen potravit.