-- Задание 4: Доля продаж с НДС по дню/магазину/группе товаров

CREATE OR ALTER PROCEDURE [dbo].[sp_report_1]
	@date_from date,
	@date_to date,
	@good_group_name nvarchar(MAX)
AS
BEGIN
	DECLARE @date_from_int int;
	DECLARE @date_to_int int;

	SELECT @date_from_int = did FROM dim_date WHERE d = @date_from;
	SELECT @date_to_int = did FROM dim_date WHERE d = @date_to;

	-- Общая сумма продаж по дню/магазину/группе
	WITH sales_cte AS (
		SELECT 
			d.d AS [Дата],
			s.store_name AS [Аптека],
			g.group_name AS [Группа товара],
			g.good_name AS [Номенклатура],
			SUM(f.sale_grs) AS [Продажи руб., с НДС]
		FROM fct_cheque f
		JOIN dim_goods g ON g.good_id = f.good_id
		JOIN dim_stores s ON s.store_id = f.store_id
		JOIN dim_date d ON d.did = f.date_id
		JOIN dim_cash_register cr ON cr.cash_register_id = f.cash_register_id
		WHERE f.date_id BETWEEN @date_from_int AND @date_to_int
		  AND g.group_name IN (
			  SELECT TRIM(value) 
			  FROM STRING_SPLIT(@good_group_name, ',')
		  )
		GROUP BY d.d, s.store_name, g.group_name, g.good_name
	),
	summary_cte AS (
		SELECT 
			[Дата],
			[Аптека],
			[Группа товара],
			SUM([Продажи руб., с НДС]) AS [Итого продаж, руб., с НДС]
		FROM sales_cte
		GROUP BY [Дата], [Аптека], [Группа товара]
	)

	SELECT 
		s.[Дата],
		s.[Аптека],
		s.[Группа товара],
		s.[Номенклатура],
		s.[Продажи руб., с НДС],
		ROUND(s.[Продажи руб., с НДС] / NULLIF(sum_cte.[Итого продаж, руб., с НДС], 0) * 100, 2) AS [Доля продаж, %]
	FROM sales_cte s
	JOIN summary_cte sum_cte 
		ON s.[Дата] = sum_cte.[Дата]
		AND s.[Аптека] = sum_cte.[Аптека]
		AND s.[Группа товара] = sum_cte.[Группа товара]
	ORDER BY [Доля продаж, %] DESC;
END;
