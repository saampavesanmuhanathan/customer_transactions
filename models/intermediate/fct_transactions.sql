WITH transactions_base AS (
    SELECT *
    FROM {{ ref('stg_shop__transactions') }}
),

products_base AS (
    SELECT *
    FROM {{ ref('stg_shop__products') }}
)

SELECT
    tb.customer_id,
    tb.transaction_id,
    pb.product_id,
    tb.quantity,
    pb.price_gbp,
    (tb.quantity * pb.price_gbp) AS total_amount_spent
FROM transactions_base tb
LEFT JOIN products_base pb
    ON tb.product_id = pb.product_id