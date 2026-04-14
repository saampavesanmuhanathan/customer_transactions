WITH dim_customer AS (
    SELECT *
    FROM {{ ref('dim_customer') }} 
),

fct_transactions AS (
    SELECT *
    FROM {{ ref('fct_transactions') }}
),

joined_aggregate AS (
    SELECT
        dc.customer_id,
        dc.gender,
        dc.age,
        dc.country,
        ROUND((('2024-12-31' - dc.signup_date)/365.25) :: NUMERIC,2) AS account_age_years,
        MAX(ROUND((('2024-12-31' - dc.most_recent_order_date)/365.25) :: NUMERIC, 2)) AS recency_of_order_years,
        COUNT(DISTINCT ft.transaction_id) AS number_of_orders,
        SUM(ft.total_amount_spent) AS total_value_of_orders,
        ROUND((SUM(ft.total_amount_spent)/ COUNT(DISTINCT ft.transaction_id)):: NUMERIC, 2) AS avg_value_of_orders
    FROM dim_customer AS dc
    LEFT JOIN fct_transactions AS ft
        ON dc.customer_id = ft.customer_id
    GROUP BY 
        dc.customer_id,
        dc.gender,
        dc.age,
        dc.country,
        dc.signup_date
),

segmented AS (
    SELECT 
        customer_id,
        gender,
        CASE 
            WHEN age < 18 THEN 'Under 18'
            WHEN age BETWEEN 18 AND 24 THEN '18-24'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            WHEN age BETWEEN 55 AND 64 THEN '55-64'
            ELSE '65+' 
        END AS age_bracket,
        country,
        account_age_years,
        CASE 
            WHEN recency_of_order_years < 1 THEN 'Active'
            WHEN recency_of_order_years < 2 THEN 'Warm'
            WHEN recency_of_order_years < 3 THEN 'At Risk'
            WHEN recency_of_order_years >= 3 THEN 'Churned' 
        END AS recency_segment,
        CASE 
            WHEN number_of_orders = 1 THEN 'One-Time Buyer'
            WHEN number_of_orders BETWEEN 2 AND 4 THEN 'Repeat Buyer'
            WHEN number_of_orders BETWEEN 5 AND 8 THEN 'Regular Buyer'
            ELSE 'Loyal Buyer' 
        END AS frequency_segment,
        CASE 
            WHEN total_value_of_orders < 50 THEN 'Low Tier'
            WHEN total_value_of_orders < 500 THEN 'Economy'
            WHEN total_value_of_orders < 1500 THEN 'Mid Tier'
            WHEN total_value_of_orders < 2500 THEN 'Premium'
            ELSE 'VIP'
        END AS value_segment,
        avg_value_of_orders
    FROM joined_aggregate
)

SELECT *
FROM segmented
