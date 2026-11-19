## 1 шаг - Data Exploration - запросы для изучения структуры и данных

### 1.1 Смотрим столбцы и типы данных

```sql 
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'sample';
```
--- 

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

---

### 1.3 Период представленных данных (этап Data Exploration, данные еще не приведены к нужному типу данных)

```sql 
SELECT MIN(TO_DATE("Order Date", 'MM/DD/YYYY')) AS first_order_date, 
       MAX(TO_DATE("Order Date", 'MM/DD/YYYY')) AS last_order_date, 
       MIN(TO_DATE("Ship Date", 'MM/DD/YYYY')) AS first_ship_date, 
       MAX(TO_DATE("Ship Date", 'MM/DD/YYYY')) AS last_ship_date
FROM sample
```
<img width="762" height="65" alt="1 3" src="https://github.com/user-attachments/assets/4199915b-0303-46ad-90b6-9cb61ca192e8" />

---

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

---

### 1.5 Поиск дубликатов
#### Проверка уникальности Row ID  

```sql
SELECT COUNT(*) - COUNT(DISTINCT "Row ID") AS duplicate_row_ids
FROM sample 
```
#### Row ID уникален

---

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
---

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

#### Повторяющиеся комбинации имеют различные Sales, Quantity, Profit значения. Эти записи не являются дубликатами 

---

### 1.6 Проверка гранулярности данных 
```sql
SELECT AVG(average_rows_per_order)
FROM(
SELECT "Order ID", COUNT(*) AS average_rows_per_order
FROM sample
GROUP BY 1) 
```
<img width="130" height="73" alt="1 6" src="https://github.com/user-attachments/assets/747e15fc-4749-420b-888e-3b763e251a39" />
#### Среднее количество строк на заказ приблизительно равно двум 

--- 

### 1.7 Категориальный анализ - какие категории, регионы и сегменты представлены в наборе данных 
```sql
SELECT "Category", 
	   COUNT(*) AS total_rows, 
	   SUM("Quantity") AS units_sold
FROM sample
GROUP BY "Category"
ORDER BY units_sold DESC 
```
<img width="477" height="127" alt="1 7" src="https://github.com/user-attachments/assets/a7d9beeb-9135-4180-91f0-d7e8c60a1bbc" />

#### Считаем долю каждой категории в наборе данных 

```sql
SELECT "Category", 
		ROUND(units_sold::DECIMAL / SUM(units_sold) OVER() * 100, 2) AS category_ratio
FROM(
SELECT "Category", 
	   COUNT(*) AS total_rows, 
	   SUM("Quantity") AS units_sold
FROM sample
GROUP BY "Category") 
ORDER BY category_ratio DESC
```

<img width="348" height="86" alt="1 7 2" src="https://github.com/user-attachments/assets/8193ed6d-b228-4323-b37e-e5ca6565dfcc" />

#### Явным лидером является Office Supplies, рассмотрим подкатегории, формирующие этот результат
```sql
SELECT "Category", 
	   "Sub-Category", 
	   COUNT(*) AS total_rows, 
	   SUM("Quantity") AS units_sold
FROM sample 
GROUP BY 1, 2
ORDER BY units_sold DESC 

```
<img width="642" height="332" alt="1 7 3" src="https://github.com/user-attachments/assets/f7d501c1-9e56-471c-8b1c-951d3042c4b2" />
---

### 1.8 Исследуем сегменты, чтобы выяснить, какой тип клиентов формирует основную часть заказов 

```sql
SELECT "Segment", 
	COUNT(DISTINCT "Customer ID") AS total_customers, 
	COUNT(DISTINCT "Order ID") AS total_orders, 
	SUM("Quantity") AS units_sold
FROM sample 
GROUP BY 1 
ORDER BY units_sold DESC
```
<img width="675" height="113" alt="1 8" src="https://github.com/user-attachments/assets/d122ed60-551f-4ab9-a817-1a9155a9bc22" />

#### Consumer - лидирующий клиентский сегмент. Сравнение сегментов производилось по количеству уникальных заказов, клиентов и проданных единиц 

---

### 1.9 Географическое распределение 

```sql
SELECT "Region", 
	COUNT(DISTINCT "Customer ID") AS total_customers, 
	COUNT(DISTINCT "Order ID") AS total_orders, 
	SUM("Quantity") AS units_sold
FROM sample
GROUP BY 1 
ORDER BY units_sold DESC 
```
<img width="651" height="130" alt="1 9" src="https://github.com/user-attachments/assets/b09b5336-e6c0-4e73-afc5-a1c1f56b8efa" />

#### West - лидирующий регион по всем параметрам 
---
### 1.10 Распределение по способу доставки 

```sql
SELECT "Ship Mode", 
	COUNT(DISTINCT "Customer ID") AS total_customers, 
	COUNT(DISTINCT "Order ID") AS total_orders 
FROM sample
GROUP BY 1 
ORDER BY total_orders DESC 
```
<img width="532" height="138" alt="1 10" src="https://github.com/user-attachments/assets/07b3599f-5e8d-448d-ada5-15fe0d0d9919" />
#### Standart Class - наиболее распространенный способ доставки 

---

### 1.11 Обзор числовых показателей. 
#### Смотрим на: Sales, Profit, Discount, Quantity. 
#### Для каждого показателя найдем минимальное, максимальное, среднее значение и сумму 

```sql
SELECT
    MIN("Sales") AS min_sales,
    MAX("Sales") AS max_sales,
    ROUND(AVG("Sales")::DECIMAL, 2) AS avg_sales,
    ROUND(SUM("Sales")::DECIMAL, 2) AS total_sales,

    MIN("Profit") AS min_profit,
    MAX("Profit") AS max_profit,
    ROUND(AVG("Profit")::DECIMAL, 2) AS avg_profit,
    ROUND(SUM("Profit")::DECIMAL, 2) AS total_profit,

    MIN("Discount") AS min_discount,
    MAX("Discount") AS max_discount,
    ROUND(AVG("Discount")::DECIMAL, 2) AS avg_discount,

    MIN("Quantity") AS min_quantity,
    MAX("Quantity") AS max_quantity,
    ROUND(AVG("Quantity")::DECIMAL, 2) AS avg_quantity,
    SUM("Quantity") AS total_quantity
FROM sample
```

<img width="1281" height="73" alt="1 11" src="https://github.com/user-attachments/assets/33e44344-bbbc-413b-ab12-abd8f9d53ec8" />
<img width="1242" height="82" alt="1 11 2" src="https://github.com/user-attachments/assets/4bf0275c-307c-4513-a084-142b8ff6e797" />

### Выводы по 1 этапу:
* Структура данных: 9994 строки, 5009 уникальных заказов, 793 клиента и 1862 уникальных товара  
* Период данных: с 3 января 2014 года по 5 января 2018 года
* Категории товаров: Office Supplies лидируют по количеству проданных единиц - 22906 товаров
* Подкатегории товаров: наибольшее кол-во проданных единиц приходится на Binders (5974) и Paper (5178)
* Клиентские сегменты: Consumer лидирует по кол-ву клиентов, заказов и проданных единиц
* География продаж: регион West лидирует по кол-ву клиентов, заказов и проданных единиц
* Способы доставки: Standart Class - наиболее распространенный способ доставки
* Финансовые показатели: общая сумма продаж - 2 297 220, общая прибыль 286 397. В данных присутствуют строки с отрицательной прибылью
* Средняя скидка составляет 16%, а общее количество проданных единиц - 37 873



