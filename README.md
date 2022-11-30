SQL projekt
 
Vypracování projektu v rámci kurzu datové akademie od společnosti Engeto.

Datové sady

Primární tabulky:
1. czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
2. czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
3. czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
4. czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
5. czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
6. czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
7. czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.

Číselníky sdílených informací o ČR:
1. czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
2. czechia_district – Číselník okresů České republiky dle normy LAU.

Dodatečné tabulky:
1. countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
2. economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

Výzkumné otázky

1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Odpovědi na výzkumné otázky jsou uvedeny v souboru Research_questions.sql

V obou zdrojových tabulkách jsem se snažil vyfiltrovat hodnoty NULL, které jsem uznal, že by mohly zkreslit data. Do obou tabulek jsem se snažit nedávat data, které nevyužiji pro výzkumné otázky.

Při vypracování odpovědí na otázky jsem vždy používal vytvoření VIEW, které jsem rozšiřoval o data, které jsem potřeboval znázornit. Do zdrojových tabulek jsem již nezasahoval.

Při využívání funkce LEAD jsem musel využít knowledge base k MariaDB, jelikož jsem potřeboval pochopit, jak nastavit správně parametry této funkce.
