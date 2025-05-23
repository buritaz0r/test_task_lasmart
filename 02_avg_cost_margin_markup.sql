-- Задание 2: Расчёт средней закупки, маржи и наценки БЕЗ НДС

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

	SELECT 
		d.d AS [Дата],
		s.store_name AS [Аптека],
		g.group_name AS [Группа товара],
		g.good_name AS [Номенклатура],
		SUM(f.quantity) AS [Продажи шт.],
		SUM(f.sale_net) AS [Продажи руб., без НДС],
		SUM(f.cost_net) AS [Закупка руб., без НДС],

		-- Средняя закупочная цена (взвешенная)
		CASE 
			WHEN SUM(f.quantity) > 0 THEN ROUND(SUM(f.cost_net) / SUM(f.quantity), 2)
			ELSE NULL
		END AS [Средняя цена закупки руб., без НДС],

		-- Маржа без НДС
		ROUND(SUM(f.sale_net) - SUM(f.cost_net), 2) AS [Маржа руб., без НДС],

		-- Наценка % без НДС
		CASE 
			WHEN SUM(f.cost_net) = 0 THEN NULL
			ELSE ROUND((SUM(f.sale_net) - SUM(f.cost_net)) / SUM(f.cost_net) * 100, 2)
		END AS [Наценка % без НДС]

	FROM fct_cheque f
	JOIN dim_goods g ON g.good_id = f.good_id
	JOIN dim_stores s ON s.store_id = f.store_id
	JOIN dim_date d ON d.did = f.date_id
	JOIN dim_cash_register cr ON cr.cash_register_id = f.cash_register_id
	WHERE f.date_id BETWEEN @date_from_int AND @date_to_int
	  AND g.group_name = @good_group_name
	GROUP BY d.d, s.store_name, g.group_name, g.good_name;
END;
