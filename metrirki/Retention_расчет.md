### Расчёт Retention по условиям учебной задачи 
---
```sql
   SELECT DATE_TRUNC('month', start_date)::DATE AS start_month, 
       start_date,
       action_date - start_date AS day_number, 
       ROUND(daily_users::DECIMAL / FIRST_VALUE(daily_users) OVER(PARTITION BY start_date), 2) AS retention
    FROM(SELECT start_date, action_date, COUNT(DISTINCT user_id) AS daily_users
         FROM(SELECT user_id, 
              MIN(time::DATE) OVER(PARTITION BY user_id) AS start_date, 
              time::DATE AS action_date
              FROM user_actions) t1
        GROUP BY 1, 2) t2
   ORDER BY 1, 2, 3
```
#### На основе данных в таблице user_actions рассчитайте показатель дневного Retention для всех пользователей, разбив их на когорты по дате первого взаимодействия с нашим приложением. В результат включите четыре колонки: месяц первого взаимодействия, дату первого взаимодействия, количество дней, прошедших с даты первого взаимодействия (порядковый номер дня начиная с 0), и само значение Retention.
---
### Визуализация когортного анализа

<img width="818" height="508" alt="image" src="https://github.com/user-attachments/assets/7aa4cea0-820e-44a2-b5a0-32833a703c52" />

