WITH customers_base AS (
    SELECT *
    FROM {{ ref('stg_shop__customers') }}
),

transactions_base AS (
    SELECT *
    FROM {{ ref('stg_shop__transactions') }}
),

final_joined AS (
    SELECT 
        cb.customer_id,
        cb.first_name,
        cb.last_name,
        cb.email,
        cb.age,
        cb.gender,
        cb.country,
        cb.signup_date,
        MIN(tb.transaction_date) AS first_order_date,
        MAX(tb.transaction_date) AS most_recent_order_date
    FROM customers_base cb
    LEFT JOIN transactions_base tb
        ON cb.customer_id = tb.customer_id
    GROUP BY
        cb.customer_id,
        cb.first_name,
        cb.last_name,
        cb.email,
        cb.age,
        cb.gender,
        cb.country,
        cb.signup_date
)

SELECT *
FROM final_joined