## 1 шаг - Data Exploration - запросы для изучения структуры и данных

### 1.1 Смотрим столбцы и типы данных

```sql 
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'sample';
```

### 1.2 Сколько строк, заказов, клиентов и товаров 

```sql
SELECT count(*) AS total_rows, 
	   count(DISTINCT "Order ID") AS total_orders,
	   count(DISTINCT "Customer ID") AS total_customers, 
	   count(DISTINCT "Product ID") AS total_products, 
	   count(DISTINCT "Category") AS total_category
	   FROM sample
```
<img width="985" height="141" alt="1 2" src="https://github.com/user-attachments/assets/eb95ddd6-6f2a-4fc6-85fb-aceaf216a400" />


### 1.3 Период представленных данных (этап Data Exploration, данные еще не приведены к нужному типу данных)

```sql 
SELECT MIN(TO_DATE("Order Date", 'MM/DD/YYYY')) AS first_order_date, 
       MAX(TO_DATE("Order Date", 'MM/DD/YYYY')) AS last_order_date, 
       MIN(TO_DATE("Ship Date", 'MM/DD/YYYY')) AS first_ship_date, 
       MAX(TO_DATE("Ship Date", 'MM/DD/YYYY')) AS last_ship_date
FROM sample
```
<img width="762" height="65" alt="1 3" src="https://github.com/user-attachments/assets/4199915b-0303-46ad-90b6-9cb61ca192e8" />

### 1.4 Поиск NULL-значений в данных 

```sql
SELECT
    COUNT(*) FILTER (WHERE "Order ID" IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE "Customer ID" IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE "Product ID" IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE "Sales" IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE "Profit" IS NULL) AS missing_profit,
    COUNT(*) FILTER (WHERE "Order Date" IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE "Ship Date" IS NULL) AS missing_ship_date
FROM sample
```
<img width="1098" height="66" alt="1 4" src="https://github.com/user-attachments/assets/d0468f3e-1bc9-4661-b1a3-87aa4d445a3c" />

### 1.5 Поиск дубликатов
#### Проверка уникальности Row ID  

```sql
SELECT COUNT(*) - COUNT(DISTINCT "Row ID") AS duplicate_row_ids
FROM sample 
```
#### Row ID уникален

#### Проверка повторяющихся товарных позиций 
```sql
SELECT "Order ID", 
       "Product ID", 
       COUNT(*) AS rows_count
FROM sample
GROUP BY 1, 2 
HAVING COUNT(*) > 1
ORDER BY rows_count
```
<img width="477" height="248" alt="1 5" src="https://github.com/user-attachments/assets/f744d661-a5bd-410e-9cd1-99d9c31b0847" />
#### Есть повторы товарных позиций, исследуем эти повторения

```sql
SELECT * 
FROM sample
WHERE ("Order ID", "Product ID") IN(
	SELECT "Order ID", 
       		"Product ID"
	FROM sample
	GROUP BY 1, 2 
	HAVING COUNT(*) > 1) 
ORDER BY "Order ID", "Product ID"
```
<img width="1575" height="227" alt="1 5 2" src="https://github.com/user-attachments/assets/e81e06d9-3633-4713-9bad-dad8c3a1b22f" />

























