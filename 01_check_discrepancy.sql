-- Задание 1: Проверка расхождений по продажам и количеству

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
		SUM(f.sale_grs) AS [Продажи руб., с НДС],
		SUM(f.cost_net) AS [Закупка руб., с НДС]
	FROM fct_cheque f
	JOIN dim_goods g ON g.good_id = f.good_id
	JOIN dim_stores s ON s.store_id = f.store_id
	JOIN dim_date d ON d.did = f.date_id
	JOIN dim_cash_register cr ON cr.cash_register_id = f.cash_register_id
	WHERE f.date_id BETWEEN @date_from_int AND @date_to_int
	  AND g.group_name = @good_group_name
	GROUP BY d.d, s.store_name, g.group_name, g.good_name;
END;
