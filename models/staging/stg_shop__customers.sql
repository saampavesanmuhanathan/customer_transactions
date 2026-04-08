WITH customers_base AS(
    SELECT *
    FROM {{ source('public', 'customers') }}
),

de_duplication AS (
    SELECT
        id AS customer_id,
        first_name,
        last_name,
        email,
        gender,
        age,
        country,
        ROW_NUMBER()OVER(PARTITION BY id) AS rn
    FROM customers_base
    )

SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    gender,
    age,
    country
FROM de_duplication
WHERE rn = 1
    