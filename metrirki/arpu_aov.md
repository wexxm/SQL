##Задача на расчёт накопительного ARPU, ARPPU, AOV (Running_ARPU, Running_ARPPU, Running_AOV)


```sql
WITH revenue_per_order AS(
 SELECT date, 
        SUM(order_total) AS order_total
 FROM(
    SELECT creation_time::DATE AS date, 
           order_id, 
           SUM(price)  AS order_total
    FROM(
        SELECT creation_time, 
               order_id, 
               UNNEST(product_ids) AS product_id
        FROM orders) t LEFT JOIN products USING(product_id)
        
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY 1, 2 ) t1
GROUP BY date), 
 
 first_user_action AS(
  SELECT user_id, 
         MIN(time::DATE) AS first_date
  FROM user_actions
  GROUP BY user_id),
 
 users_per_day AS(
  SELECT first_date AS date, 
         COUNT(user_id) AS total_users
  FROM first_user_action
  GROUP BY 1
 ),
 
 first_paying_action AS(
    SELECT user_id, 
        MIN(time::DATE) AS first_date
    FROM user_actions 
    WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
    GROUP BY user_id), 
 
 paying_users_per_day AS(
     SELECT first_date AS date, 
         COUNT(user_id) AS total_paying_users
     FROM first_paying_action
     GROUP BY 1
  ), 
  
  orders_per_day AS(
     SELECT creation_time::DATE AS date, 
            COUNT(order_id) AS orders_amount
     FROM orders
     WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')
     GROUP BY 1)
  
SELECT date, 
       ROUND(SUM(order_total) OVER(ORDER BY date)::DECIMAL / SUM(total_users) OVER(ORDER BY date), 2)  AS running_arpu,
       ROUND(SUM(order_total) OVER(ORDER BY date)::DECIMAL / SUM(total_paying_users) OVER(ORDER BY date), 2)  AS running_arppu, 
       ROUND(SUM(order_total) OVER(ORDER BY date)::DECIMAL / SUM(orders_amount) OVER(ORDER BY date), 2) AS running_aov
FROM revenue_per_order JOIN users_per_day USING(date) JOIN paying_users_per_day USING(date) JOIN orders_per_day USING(date) 
ORDER BY date       


```
---
### Визуализация результата

<img width="1342" height="776" alt="image" src="https://github.com/user-attachments/assets/975c48cc-c591-415f-a94c-3ca39c9314c9" />
