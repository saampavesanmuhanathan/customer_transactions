WITH transactions_base AS (
    SELECT *
    FROM {{ source('public', 'transactions') }}
),

de_duplication AS (
    SELECT
        id AS transaction_id,
        customer_id,
        product_id,
        quantity,
        transaction_date,
        ROW_NUMBER()OVER(PARTITION BY id) AS rn
    FROM transactions_base
),

filtered AS (
    SELECT 
        transaction_id,
        customer_id,
        product_id,
        quantity,
        CAST(transaction_date AS DATE) AS transaction_date
    FROM de_duplication
    WHERE rn = 1 
)

SELECT *
FROM filtered