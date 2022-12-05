-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

CREATE OR REPLACE VIEW v_select_cz_payllor AS 
SELECT 
	Year_price,
	Industry_branch,
	Pay_value
FROM 
	t_vojtech_kukac_project_SQL_primary_final
GROUP BY 
	Year_price,
	Industry_branch
ORDER BY 
	Industry_branch,
	Year_price;
	
CREATE OR REPLACE VIEW v_select_cz_payllor_growth AS
SELECT 
	Year_price,
	Industry_branch,
	Pay_value,
	LEAD (Pay_value,1) OVER (PARTITION BY Industry_branch ORDER BY Industry_branch, Year_price) Next_pay_value,
	round ((((LEAD (Pay_value,1) OVER (PARTITION BY Industry_branch ORDER BY Industry_branch, Year_price)) - Pay_value) / Pay_value) * 100,2) AS Growth
FROM
	v_select_cz_payllor
ORDER BY Industry_branch,Year_price;

SELECT
	Industry_branch,
	Round(AVG(Growth),2) AS Pay_growth
FROM v_select_cz_payllor_growth
WHERE Growth IS NOT NULL
GROUP BY Industry_branch;

-- Ve sloupci "Pay_growth" je možné vidět, že celkově ve všech odvětvích mzda v průběhu let roste.

-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

CREATE OR REPLACE VIEW v_select_year_category AS
SELECT
	AVG(Price) AS Avg_price,
	AVG(Pay_value) AS Avg_pay,
	Category,
	Quantity,
	Unit,
	Year_price
FROM 
	t_vojtech_kukac_project_SQL_primary_final
WHERE 
	Year_price IN (2006,2018) AND 
	Category IN ("Chléb konzumní kmínový","Mléko polotučné pasterované")
GROUP BY 
	Year_price, Category;
	
SELECT 
	Avg_price,
	Avg_pay,
 	Category,
 	Year_price,
	ROUND(Avg_pay / Avg_price,2) AS Quantity_goods,
	Unit
FROM 
	v_select_year_category;

-- V roce 2006 si za průměrnou mzdu bylo možné koupit 1 287,16 kg chleba nebo 1 437,46 litrů mléka.
-- V roce 2018 si za průměrnou mzdu bylo možné koupit 1 342,32 kg chleba nebo 1 641,77 litrů mléka.

-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

CREATE OR REPLACE VIEW v_cz_price_difference AS
SELECT 
	Year_price,
	Category,
	Price,
	LEAD (Price,1) OVER (PARTITION BY Category ORDER BY Category, Year_price) Next_year_price,
	ROUND ((((LEAD (Price,1) OVER (PARTITION BY Category  ORDER BY Category, Year_price)) - Price) / Price) * 100,2) Difference
FROM 
	t_vojtech_kukac_project_sql_primary_final
GROUP BY 
	Category, Year_price;
			
SELECT 
	Category,  
	ROUND(AVG (Difference),2)
FROM 
	v_cz_price_difference
GROUP BY
	Category
ORDER BY 
	AVG (Difference);

-- Z dat je možné vypozorovat, že nejpomaleji zdražující kategorie potravin je kategorie Cukr krystal.

-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

CREATE OR REPLACE VIEW v_cz_price_growth AS
SELECT 
	Year_price, 
	ROUND(AVG(Difference),2) AS Difference 
FROM v_cz_price_difference 
GROUP BY Year_price;

CREATE OR REPLACE VIEW v_cz_payllor_growth AS
SELECT 
	Year_price, 
	ROUND(AVG(Growth),2) AS Growth 
FROM v_select_cz_payllor_growth 
GROUP BY Year_price;

SELECT 
	v_cz_p.Year_price,
	v_cz_p.Difference AS Price_growth,
	v_cz_pay.Growth AS Pay_growth,
	v_cz_p.Difference - v_cz_pay.Growth AS Difference_price_pay
FROM 
	v_cz_price_growth AS v_cz_p
LEFT JOIN v_cz_payllor_growth AS v_cz_pay
	ON v_cz_p.Year_price = v_cz_pay.Year_price
ORDER BY Difference_price_pay;

-- V žádném roce nebyl nárůst cen potravit vyšší než 10%. 
-- V roce 2012 byl nejvyšší nárůst cen oporit nárůstu mezd a to bylo 9,22%.

-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

CREATE OR REPLACE VIEW v_gdp_growth AS
SELECT 
	*,
	LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, year) Next_year_GDP,
	round((((LEAD (GDP,1) OVER (PARTITION BY country ORDER BY country, year))-GDP) / GDP ) * 100,2) GDP_growth
FROM 
	t_vojtech_kukac_project_SQL_secondary_final
WHERE 
	country = LOWER("czech republic");


CREATE OR REPLACE VIEW v_cz_price_growth AS
SELECT 
	Year_price, 
	ROUND(AVG(Difference),2) AS Difference 
FROM 
	v_cz_price_difference 
GROUP BY 
	Year_price;

CREATE OR REPLACE VIEW v_cz_payllor_growth AS
SELECT 
	Year_price, 
	ROUND(AVG(Growth),2) AS Growth 
FROM 
	v_select_cz_payllor_growth 
GROUP BY 
	Year_price;

SELECT 
	v_gdp.YEAR AS Basic_year,
	v_gdp.YEAR + 1 AS Next_year,
	v_gdp.GDP_growth,
	v_cz_p.Difference AS Price_growth,
	v_cz_pay.Growth AS Pay_growth
FROM 
	v_gdp_growth AS v_gdp
LEFT JOIN v_cz_price_growth AS v_cz_p
	ON v_gdp.`year`= v_cz_p.Year_price
LEFT JOIN v_cz_payllor_growth AS v_cz_pay
	ON v_gdp.`year`= v_cz_pay.Year_price
WHERE v_gdp.YEAR >= 2006 AND v_gdp.YEAR <= 2017 ;

-- Z dat vyplývá, že výška HDP nemá přímý vliv na růst mezd nebo cen potravit.