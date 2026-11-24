### Расчёт метрики CAC - Customer Acquisition Cost по условиям учебного задания 

```sql
WITH campaign_table AS(
    SELECT user_id, 
           order_id, 
           action, 
           CASE WHEN user_id IN (8631, 8632 /*тут было перечисление айдишников рекламной кампании №1 по условиям задачи*/) THEN 1
                WHEN user_id IN (8629, 8630 /*тут было перечисление айдишников рекламной кампании №2 по условиям задачи*/) THEN 2
                ELSE 0 END AS ads_campaign, 
                COUNT(action) FILTER(WHERE action = 'cancel_order') OVER(PARTITION BY order_id) AS is_canceled
                
    FROM user_actions)
                
SELECT CONCAT('Кампания №', ads_campaign) AS ads_campaign, 
       ROUND(250000.0 / COUNT(DISTINCT user_id), 2) AS CAC 
FROM campaign_table
WHERE ads_campaign IN (1, 2) AND is_canceled = 0 
GROUP BY ads_campaign 
ORDER BY CAC DESC 
                
```
#### Условия задачи: На основе таблицы user_actions рассчитайте метрику CAC для двух рекламных кампаний.

Список id пользователей, пришедших после рекламной кампании № 1: Список id пользователей, пришедших после рекламной кампании № 2: В рекламной кампании № 1 о нашем приложении рассказал известный блогер на Youtube-канале о кулинарии. На эту интеграцию суммарно потратили 250 тысяч рублей. В результате этой кампании 1 сентября в приложении зарегистрировался 171 человек.

В рамках рекламной кампании № 2 пользователям показывали таргетированную рекламу в социальных сетях. На это тоже суммарно потратили 250 тысяч рублей, и в результате 1 сентября у нас появилось 236 новых пользователей.
