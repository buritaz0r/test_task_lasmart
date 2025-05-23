-- Удаление дубликатов в dim_goods
WITH RankedGoods AS (
  SELECT *, 
         ROW_NUMBER() OVER (PARTITION BY good_id ORDER BY group_name) AS rn
  FROM dim_goods
)
DELETE FROM RankedGoods WHERE rn > 1;

-- Удаление дубликатов в dim_cash_register
WITH RankedCash AS (
  SELECT *, 
         ROW_NUMBER() OVER (PARTITION BY cash_register_id ORDER BY cash_register_number) AS rn
  FROM dim_cash_register
)
DELETE FROM RankedCash WHERE rn > 1;

-- Добавление недостающих аптек из фактов
INSERT INTO dim_stores (store_id, store_name)
SELECT DISTINCT store_id, CONCAT(N'Аптека - ', store_id)
FROM fct_cheque
WHERE store_id NOT IN (SELECT store_id FROM dim_stores);

-- Добавление недостающих касс из фактов
INSERT INTO dim_cash_register (cash_register_id, cash_register_number)
SELECT DISTINCT cash_register_id, CONCAT(N'касса - ', cash_register_id)
FROM fct_cheque
WHERE cash_register_id NOT IN (SELECT cash_register_id FROM dim_cash_register);
