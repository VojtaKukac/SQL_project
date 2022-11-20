CREATE OR REPLACE TABLE t_vojtech_kukac_project_SQL_primary_final AS 
SELECT 
	cz_p.value AS Price,
	cz_pc.name AS Category,
	cz_pc.price_value AS Quantity,
	cz_pc.price_unit AS Unit,
	YEAR(cz_p.date_to) AS Year_price,
	cz_pay.value AS Pay_value,
	cz_pay_in_br.name AS Industry_branch
FROM czechia_price AS cz_p
JOIN czechia_payroll AS cz_pay
	ON YEAR(cz_p.date_from) = cz_pay.payroll_year
LEFT JOIN czechia_price_category AS cz_pc
	ON cz_pc.code = cz_p.category_code
LEFT JOIN czechia_payroll_industry_branch AS cz_pay_in_br
	ON cz_pay.industry_branch_code = cz_pay_in_br.code
WHERE 
	cz_pay.value IS NOT NULL AND 
	cz_pay.value_type_code = 5958 AND 
	cz_pay_in_br.name IS NOT NULL
;