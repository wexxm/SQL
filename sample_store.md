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


### 1.3 Период представленных данных 

```sql 
SELECT min("Order Date"), min("Ship Date"), max("Order Date"), max("Ship Date") FROM sample
```
