WITH customers_base AS (
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
        CAST(signup_date AS DATE) AS signup_date,
        ROW_NUMBER()OVER(PARTITION BY id) AS rn
    FROM customers_base
),

filtered AS (
    SELECT 
        customer_id,
        first_name,
        last_name,
        email,
        gender,
        age,
        country,
        signup_date
    FROM de_duplication
    WHERE rn = 1
)

SELECT *
FROM filtered