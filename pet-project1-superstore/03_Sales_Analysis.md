## Этап 3 - Sales Analysis - анализ продаж. 
---
### 3.1 Общие показатели продаж 
#### Рассмотрим:
    - Общую выручку - total_sales
    - Общую прибыль - total_profit
    - Количество уникальных заказов - total_orders
    - Количество клиентов - total_clients 
    - Количество проданных единиц - total_quantity
    - Рентабельность продаж в процентах - profit_margin 

```sql
SELECT
    SUM("Sales") AS total_sales,
    SUM("Profit") AS total_profit,
    COUNT(DISTINCT "Order ID") AS total_orders,
    COUNT(DISTINCT "Customer ID") AS total_customers,
    SUM("Quantity") AS total_quantity,
    ROUND(SUM("Profit")::DECIMAL / SUM("Sales")::DECIMAL * 100, 2) AS profit_margin
FROM sample

``` 
<img width="1072" height="67" alt="3" src="https://github.com/user-attachments/assets/b33e98b7-3ba8-405d-8a05-26e36c954c7c" />

---
#### Рентабельность составила 12,47%, то есть на каждые 100 денежных единиц приходится 12,47 единиц прибыли

---

### 3.2 Динамика продаж по годам 

```sql 
SELECT EXTRACT(YEAR FROM "Order Date" ) AS YEAR, 
		SUM("Sales") AS total_sales, 
		SUM("Profit") AS total_profit,
		COUNT(DISTINCT "Order ID") AS total_orders
FROM sample 		
GROUP BY 1
ORDER BY year
```

<img width="657" height="148" alt="3 1" src="https://github.com/user-attachments/assets/8c57df2a-3c40-4fbc-bd68-c77eb41884a4" />
