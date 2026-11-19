## Этап 3 - Sales Analysis - анализ продаж. 
---
### 3.1 Общие показатели продаж 
#### Рассмотрим:
    * Общую выручку - total_sales
    * Общую прибыль - total_profit
    * Количество уникальных заказов - total_orders
    * Количество клиентов - total_clients 
    * Количество проданных единиц - total_quantity
    * Рентабельность продаж в процентах - profit_margin 

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
