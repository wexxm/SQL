### Расчет ROI - Return Of Investment по условиям учебной задачи 
---
```sql
WITH total_user_orders AS(
    SELECT order_id,
           SUM(price) AS order_amount
           
    FROM(SELECT order_id, 
         UNNEST(product_ids) AS product_id
         FROM orders) t LEFT JOIN products USING(product_id)
    GROUP BY order_id), 



campaign_table AS(
    SELECT user_id, 
           order_id, 
           action, 
           CASE WHEN user_id IN (8631, 8632 /*тут были айдишники кампании № 1 по условиям задачи*/) THEN 1
                WHEN user_id IN (8629, 8630 /*тут были айдишники кампании № 2 по условиям задачи*/) THEN 2
                ELSE 0 END AS ads_campaign, 
                COUNT(action) FILTER(WHERE action = 'cancel_order') OVER(PARTITION BY order_id) AS is_canceled 

                
    FROM user_actions)
    

                
SELECT CONCAT('Кампания № ', ads_campaign) AS ads_campaign, 
       ROUND((SUM(order_amount) - 250000) / 250000.0 * 100, 2) AS ROI 
FROM campaign_table LEFT JOIN total_user_orders USING(order_id)
WHERE ads_campaign IN (1, 2) AND is_canceled = 0 
GROUP BY ads_campaign 
ORDER BY ROI DESC 
                
```

### Рассчитайте ROI для каждого рекламного канала. Колонку с наименованиями кампаний назовите ads_campaign, а колонку со значением метрики — roi.
---
### Визуализация результата 

<img width="1346" height="427" alt="image" src="https://github.com/user-attachments/assets/7623c19d-baf2-44ce-975c-92aa734adc1d" />
