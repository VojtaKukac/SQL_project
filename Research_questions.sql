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
	Round(AVG(Growth),2)
FROM v_select_cz_payllor_growth
WHERE Growth IS NOT NULL
GROUP BY Industry_branch;

-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

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

-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

-- 5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
