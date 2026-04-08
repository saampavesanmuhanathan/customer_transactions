WITH products_base AS(
    SELECT *
    FROM {{ source('public', 'products') }}
),

de_duplication AS(
    SELECT
        id AS product_id,
        name AS product_name,
        category AS product_category,
        price_gbp,
        ROW_NUMBER()OVER(PARTITION BY id) AS rn
    FROM products_base
)

SELECT 
    product_id,
    product_name,
    price_gbp,
    product_category
FROM de_duplication
WHERE rn = 1