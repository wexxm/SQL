## 2 этап - Data_Cleaning - очистка данных перед анализом 
---
### 2.1 Проверка пропусков во всех столбцах 
```sql
SELECT
    COUNT(*) FILTER (WHERE "Row ID" IS NULL) AS missing_row_id,
    COUNT(*) FILTER (WHERE "Order ID" IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE "Order Date" IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE "Ship Date" IS NULL) AS missing_ship_date,
    COUNT(*) FILTER (WHERE "Ship Mode" IS NULL) AS missing_ship_mode,
    COUNT(*) FILTER (WHERE "Customer ID" IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE "Customer Name" IS NULL) AS missing_customer_name,
    COUNT(*) FILTER (WHERE "Segment" IS NULL) AS missing_segment,
    COUNT(*) FILTER (WHERE "Country" IS NULL) AS missing_country,
    COUNT(*) FILTER (WHERE "City" IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE "State" IS NULL) AS missing_state,
    COUNT(*) FILTER (WHERE "Postal Code" IS NULL) AS missing_postal_code,
    COUNT(*) FILTER (WHERE "Region" IS NULL) AS missing_region,
    COUNT(*) FILTER (WHERE "Product ID" IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE "Category" IS NULL) AS missing_category,
    COUNT(*) FILTER (WHERE "Sub-Category" IS NULL) AS missing_sub_category,
    COUNT(*) FILTER (WHERE "Product Name" IS NULL) AS missing_product_name,
    COUNT(*) FILTER (WHERE "Sales" IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE "Quantity" IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE "Discount" IS NULL) AS missing_discount,
    COUNT(*) FILTER (WHERE "Profit" IS NULL) AS missing_profit
FROM sample
```
#### В нашем учебном дата-сете нет NULL-значений 
---
### 2.2 Проверяем, есть ли полностью идентичные строки в таблице 
```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (
        "Row ID", "Order ID", "Order Date", "Ship Date",
        "Ship Mode", "Customer ID", "Customer Name",
        "Segment", "Country", "City", "State", "Postal Code",
        "Region", "Product ID", "Category", "Sub-Category",
        "Product Name", "Sales", "Quantity", "Discount", "Profit"
    )) AS unique_rows
FROM sample
```
<img width="331" height="73" alt="2 2" src="https://github.com/user-attachments/assets/c00370f8-63c0-4412-be31-ad928b5a6531" />
#### Полных дубликатов в таблице нет, удаление дубликатов не требуется 
---
### 2.3 Преобразование типов 
#### Order Date и Ship Date не имеют тип Date, преобразовываем их в нужные типы 

```sql
ALTER TABLE sample 
ALTER COLUMN "Ship Date"
TYPE DATE
USING TO_DATE("Ship Date", 'MM/DD/YYYY')

ALTER TABLE sample 
ALTER COLUMN "Order Date"
TYPE DATE
USING TO_DATE("Order Date", 'MM/DD/YYYY')
```

#### Теперь все данные имеют верный тип данных в БД 

---
### 2.4 Проверка корректности значений 
#### Числовые показатели: есть ли продажи меньше или равные нулю, нулевые значения количества товаров, скидки за пределами допустимого диапазона (от 0 до 1) 
```sql
SELECT
    COUNT(*) FILTER (WHERE "Sales" <= 0) AS invalid_sales,
    COUNT(*) FILTER (WHERE "Quantity" <= 0) AS invalid_quantity,
    COUNT(*) FILTER (WHERE "Discount" < 0 OR "Discount" > 1) AS invalid_discount
FROM sample
```
#### Некорректные значения отсутствуют 
<img width="567" height="57" alt="2 4" src="https://github.com/user-attachments/assets/e1337b01-31fa-4c35-983a-19249ef3bcfe" />

--- 
### Проверка дат 
```sql
SELECT
    COUNT(*) FILTER (WHERE "Ship Date" < "Order Date") AS invalid_dates
FROM sample
```
#### Некорректные значения отсутствуют 

---
### Проверка категориальных значений 
#### Теперь нужно убедиться, что в текстовых полях нет неожиданных значений, опечаток или лишних вариантов категорий
``` sql
-- 02.5. Проверка уникальных категориальных значений

SELECT DISTINCT "Segment"
FROM sample
ORDER BY "Segment"

SELECT DISTINCT "Region"
FROM sample
ORDER BY "Region"

SELECT DISTINCT "Category"
FROM sample
ORDER BY "Category"

SELECT DISTINCT "Ship Mode"
FROM sample
ORDER BY "Ship Mode"
```
#### Некорректные значения отсутствуют 
---
### Проверка целостности данных 
#### Проверка соответствия ID и названий товаров 
```sql
SELECT
    "Product ID",
    COUNT(DISTINCT "Product Name") AS name_count
FROM sample
GROUP BY "Product ID"
HAVING COUNT(DISTINCT "Product Name") > 1
```
<img width="336" height="341" alt="2 4 2" src="https://github.com/user-attachments/assets/9777aced-76d1-48d1-85ed-d1f26cef7be0" />

#### Одному Product ID соответствуют 2 Product Name. Изучаем несоответствия 

```sql
SELECT DISTINCT
    "Product ID",
    "Product Name"
FROM sample
WHERE "Product ID" IN (
    SELECT "Product ID"
    FROM sample
    GROUP BY "Product ID"
    HAVING COUNT(DISTINCT "Product Name") > 1
)
ORDER BY "Product ID", "Product Name";

```
<img width="803" height="337" alt="2 4 3" src="https://github.com/user-attachments/assets/7cc2e5ae-f4e8-4ead-97d5-3b9cf99fdd1e" />
#### Похоже на то, что есть нарушения в данных. Нельзя использовать Product ID для дальнейшего анализа ассортимента, приведет к некорректным результатам 
#### Сколько всего идентификаторов товаров имеют несколько названий ? 











