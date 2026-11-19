## 1. Data Exploration - запросы для изучения структуры и данных

### 1.1 Смотрим столбцы и типы данных

```sql 
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'sample';```

###1.2 


###1.3 Период представленных данных 

```sql 
SELECT min("Order Date"), min("Ship Date"), max("Order Date"), max("Ship Date") FROM sample
```
