-- ==============================================================================
-- ENIAC & MAGIST BUSINESS EXPANSION CASE STUDY
-- PART 1: PRODUCT & MARKET SUITABILITY ANALYSIS (TECH PORTFOLIO)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 0: Data Exploration
-- Purpose: Overview of the category product translation table
-- ------------------------------------------------------------------------------

SELECT 
    *
FROM
    product_category_name_translation
ORDER BY product_category_name_english ASC;

-- ------------------------------------------------------------------------------
-- Query 1: Tech Categories Mapping
-- Purpose: Filter and verify the translation mapping for target Tech products.
-- ------------------------------------------------------------------------------

SELECT 
product_category_name AS portoghese_categories,
product_category_name_english AS english_categories
FROM 
product_category_name_translation
WHERE 
product_category_name IN (
	'audio', 
    'cine_foto', 
    'pcs', 
    'informatica_acessorios', 
    'consoles_games', 
    'eletronicos', 
    'telefonia_fixa', 
    'pc_gamer', 
    'sinalizacao_e_seguranca', 
    'tablets_impressao_imagem', 
    'telefonia', 
    'relogios_presentes'
)
ORDER BY english_categories ASC;

-- ------------------------------------------------------------------------------
-- Query 2: Market Share of Tech Products
-- Purpose: Calculate total tech volume vs. global volume to measure category demand.
-- Baseline Metrics: Total Tech Units = 23,461 | Global Units = 112,650
-- Expected Share: 20.83%
-- ------------------------------------------------------------------------------
-- 2.1: Count total tech units sold

SELECT 
    COUNT(*) AS total_tech_products_sold
FROM
    order_items AS oi
        INNER JOIN
    products AS p ON oi.product_id = p.product_id
        INNER JOIN
    product_category_name_translation AS pr ON p.product_category_name = pr.product_category_name
WHERE
p.product_category_name IN(
	'audio', 
    'cine_foto', 
    'pcs', 
    'informatica_acessorios', 
    'consoles_games', 
    'eletronicos', 
    'telefonia_fixa', 
    'pc_gamer', 
    'sinalizacao_e_seguranca', 
    'tablets_impressao_imagem', 
    'telefonia', 
    'relogios_presentes'
);

-- 2.2: Count absolute global units sold

SELECT COUNT(*) AS total_products_sold FROM order_items;

-- 2.3: Ratio calculation

SELECT ROUND((23461 / 112650) * 100, 2) AS tech_percentage;

-- ------------------------------------------------------------------------------
-- Query 3: Pricing Premium Analysis
-- Purpose: Compare global average price vs. tech average price.
-- Findings: Global Average = 120.65 BRL | Tech Average = 133.37 BRL (+10.5%)
-- ------------------------------------------------------------------------------
-- 3.1: Global average price

SELECT ROUND(AVG(price), 2) AS average_total_price
FROM order_items;

-- 3.2: Tech average price

SELECT 
    ROUND(AVG(oi.price), 2) AS average_tech_price
FROM
    order_items AS oi
        INNER JOIN
    products AS p ON oi.product_id = p.product_id
        INNER JOIN
    product_category_name_translation AS pr ON p.product_category_name = pr.product_category_name
WHERE
p.product_category_name IN(
	'audio', 
    'cine_foto', 
    'pcs', 
    'informatica_acessorios', 
    'consoles_games', 
    'eletronicos', 
    'telefonia_fixa', 
    'pc_gamer', 
    'sinalizacao_e_seguranca', 
    'tablets_impressao_imagem', 
    'telefonia', 
    'relogios_presentes'
);

-- ------------------------------------------------------------------------------
-- Query 4: Customer Price Segmentation (Percentile Method)
-- Purpose: Define strict thresholds to evaluate customer appetite for premium goods.
-- Methodology: 
-- - 25th Percentile (Cheap) position: 23,461 * 0.25 = 5,865 -> Threshold: 29 BRL
-- - 75th Percentile (Expensive) position: 23,461 * 0.75 = 17,595 -> Threshold: 150 BRL
-- ------------------------------------------------------------------------------
-- 4.1: Find 75th percentile threshold (Expensive products)

SELECT ROUND(oi.price, 2) AS threshold_75_percentile
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IN (
    'audio', 'cine_foto', 'pcs', 'informatica_acessorios', 'consoles_games', 
    'eletronicos', 'telefonia_fixa', 'pc_gamer', 'sinalizacao_e_seguranca', 
    'tablets_impressao_imagem', 'telefonia', 'relogios_presentes'
)
ORDER BY oi.price ASC
LIMIT 1 OFFSET 17595;

-- 4.2: Find 25th percentile threshold (Cheap products)

SELECT ROUND(oi.price, 2) AS threshold_percentile
FROM order_items oi
INNER JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IN (
    'audio', 'cine_foto', 'pcs', 'informatica_acessorios', 'consoles_games', 
    'eletronicos', 'telefonia_fixa', 'pc_gamer', 'sinalizacao_e_seguranca', 
    'tablets_impressao_imagem', 'telefonia', 'relogios_presentes'
)
ORDER BY oi.price ASC
LIMIT 1 OFFSET 5868;

-- 4.4: Aggregated distribution and volume share per price segment
-- Business Insight: High-end tech products (Expensive) generate ~68.06% of the revenue.

SELECT 
    CASE 
        WHEN oi.price < 29 THEN 'Cheap'
        WHEN oi.price BETWEEN 29 AND 149.89 THEN 'Medium'
        ELSE 'Expensive'
    END AS price_segment,
    COUNT(*) AS total_products,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM
    order_items AS oi
INNER JOIN
    products AS p ON oi.product_id = p.product_id
WHERE
    p.product_category_name IN (
        'audio', 
        'cine_foto', 
        'pcs', 
        'informatica_acessorios', 
        'consoles_games', 
        'eletronicos', 
        'telefonia_fixa', 
        'pc_gamer', 
        'sinalizacao_e_seguranca', 
        'tablets_impressao_imagem', 
        'telefonia', 
        'relogios_presentes'
    )
GROUP BY 
    price_segment;

-- ==============================================================================
-- ENIAC & MAGIST BUSINESS EXPANSION CASE STUDY
-- PART 2: SELLER ECOSYSTEM & REVENUE ANALYSIS
-- ==============================================================================

-- Query 5: Database Time Window Calculation
-- Purpose: Extract the active months in the dataset using DATE_FORMAT to count rows.
-- Metric Result: 25 distinct months
-- ------------------------------------------------------------------------------

SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS year__month
FROM orders
GROUP BY DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY year__month;

-- ------------------------------------------------------------------------------
-- Query 6: Seller Count and Tech Specialization
-- Purpose: Calculate total sellers vs. active tech sellers to evaluate the network.
-- Metrics: Total Sellers = 3,095 | Tech Sellers = 587
-- Expected Share: 18.97% (~1 in 5 sellers already handling electronics)
-- ------------------------------------------------------------------------------
-- 6.1: Global active sellers count

SELECT
COUNT(DISTINCT seller_id) AS number_of_sellers
FROM sellers;

-- 6.2: Tech specialized sellers count

SELECT 
    COUNT( DISTINCT oi.seller_id) AS total_tech_sellers
FROM
    order_items oi
        INNER JOIN
    products p USING (product_id)
WHERE 
p.product_category_name IN (
        'audio', 
        'cine_foto', 
        'pcs', 
        'informatica_acessorios', 
        'consoles_games', 
        'eletronicos', 
        'telefonia_fixa', 
        'pc_gamer', 
        'sinalizacao_e_seguranca', 
        'tablets_impressao_imagem', 
        'telefonia', 
        'relogios_presentes'
);

-- 6.3: Ratio calculation

SELECT ROUND((587 / 3095) * 100, 2) AS tech_sellers_percentage;

-- ------------------------------------------------------------------------------
-- Query 7: Platform Revenue Distribution
-- Purpose: Compare global gross merchandise volume (GMV) vs. strict tech products GMV.
-- Metrics: Global Revenue = 13,591,643.70 BRL | Strict Tech Revenue = 3,129,091.16 BRL
-- ------------------------------------------------------------------------------
-- 7.1: Total revenue moved by all categories

SELECT ROUND(SUM(price),2) AS total_profit 
FROM order_items;

-- 7.2: Total revenue strictly generated by tech items

SELECT ROUND(SUM(price),2) AS total_sales
FROM order_items o
INNER JOIN products p
USING (product_id)
WHERE p.product_category_name IN (
        'audio', 
        'cine_foto', 
        'pcs', 
        'informatica_acessorios', 
        'consoles_games', 
        'eletronicos', 
        'telefonia_fixa', 
        'pc_gamer', 
        'sinalizacao_e_seguranca', 
        'tablets_impressao_imagem', 
        'telefonia', 
        'relogios_presentes'
);

-- ------------------------------------------------------------------------------
-- Query 8: Average Monthly Financial Volumes
-- Purpose: Calculate overall monthly marketplace income vs. tech category monthly volume
-- Metrics: Global Monthly Avg = 543,665.75 BRL | Tech Monthly Avg = 125,163.65 BRL.
-- ------------------------------------------------------------------------------
-- 8.1: Average monthly revenue across all marketplace operations

SELECT 
ROUND(13591643.7 / 25, 2) AS average_monthly_income_per_seller;

-- 8.2: Average monthly revenue generated specifically by the tech sector

SELECT
ROUND(3129091.16 / 25, 2) AS average_monthly_income_tech_sellers;


-- ==============================================================================
-- PART 3: LOGISTICS & DELIVERY PERFORMANCE ANALYSIS
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- Query 9: Average Lead Time Calculation
-- Purpose: Measure average days between customer order placement and actual doorstep delivery.
-- Metric Result: 12.50 days average
-- ------------------------------------------------------------------------------

SELECT 
ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),2)
AS average_days_of_delivery
FROM orders
WHERE 
    order_status = 'delivered';

-- ------------------------------------------------------------------------------
-- Query 10: On-Time vs Delayed Deliveries Volume
-- Purpose: Extract absolute volumes of punctual shipments vs. delayed ones.
-- Condition: DATEDIFF > 0 between actual and estimated dates defines a delay.
-- Metric Result: On-Time = 89,805 orders | Delayed = 6,665 orders
-- ------------------------------------------------------------------------------

SELECT 
    CASE
        WHEN
            DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date) > 0
        THEN
            'Delayed'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM
    orders
WHERE
    order_status = 'delivered' 
        AND order_delivered_customer_date IS NOT NULL  
GROUP BY delivery_status;

-- ------------------------------------------------------------------------------
-- Query 11: Logistics Pattern Hunting (Physical Attributes Analysis)
-- Purpose: Analyze physical metrics (weight and dimensions) to identify bottlenecks.
-- Findings: Delayed items are 19% heavier (2,452g vs 2,064g). 
--           Geometric dimensions (length, height, width) show no significant variation.
-- ------------------------------------------------------------------------------

SELECT 					
    CASE 
    WHEN     DATEDIFF(order_delivered_customer_date,
            order_estimated_delivery_date) > 0 THEN "Delayed"
	ELSE "On Time"
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(AVG(p.product_weight_g),0) AS avg_product_weight,
    ROUND(AVG(p.product_length_cm),0) AS avg_product_length,
    ROUND(AVG(product_height_cm),0) AS avg_product_height,
    ROUND(AVG(product_width_cm),0)AS avg_product_width
FROM
    products p
        INNER JOIN
    order_items oi USING (product_id)
        INNER JOIN
    orders o USING (order_id)
WHERE
order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL 
GROUP BY 
delivery_status;
            

