-- SUPPLY CHAIN PERFORMANCE & RISK ANALYTICS

/* OVERALL DELIVERY PERFORMANCE 
Purpose : Establish the overall delivery performance baseline.
Analysis : 
	1. Overall dataset volume
	2. Delivery status distribution
	3. Dataset-defined late delivery rate
	4. Shipping duration variance
	5. Shipping performance distribution
	6. Delivery status versus calculated shipping performance
Source : DataCo Smart Supply Chain Dataset
Cleaned dataset : 180,519 rows and 55 columns
*/

USE supply_chain_analytics ; 

-- 1. OVERALL DATASET VOLUME
-- Business question:
-- How much order-item data are we analyzing?

SELECT 
	COUNT(*) AS total_order_items, 
    COUNT(DISTINCT `Order Id`) AS total_orders, 
    COUNT(DISTINCT `Order Customer Id`) AS unique_customers, 
    COUNT(DISTINCT `Product Card Id`) AS unique_products 
FROM supply_chain_orders ; 

-- 2. DELIVERY STATUS DISTRIBUTION
-- Business question:
-- How are order items distributed across delivery statuses?

WITH DeliveryStatusCounts AS (
    SELECT 
        `Delivery Status` AS delivery_status, 
        COUNT(*) AS order_item_count, 
        SUM(COUNT(*)) OVER () AS total_dataset_items 
    FROM supply_chain_orders 
    GROUP BY `Delivery Status` 
)
SELECT 
    delivery_status, 
    order_item_count, 
    ROUND(100.0 * order_item_count / NULLIF(total_dataset_items, 0), 2) AS percentage_of_order_items 
FROM DeliveryStatusCounts 
ORDER BY order_item_count DESC ; 

-- 3. DATASET-DEFINED LATE DELIVERY RATE
-- Business question:
-- What percentage of order items are labelled "Late delivery"?

WITH LateDeliverySummary AS (
    SELECT 
        COUNT(*) AS total_order_items, 
        SUM(
			CASE 
				WHEN `Delivery Status` = 'Late delivery' THEN 1 
                ELSE 0 
			END
		) AS late_order_items 
    FROM supply_chain_orders 
) 
SELECT 
    total_order_items, 
    late_order_items, 
    ROUND(100.0 * late_order_items / NULLIF(total_order_items, 0), 2) AS late_delivery_rate_pct 
FROM LateDeliverySummary ; 

-- 4. SHIPPING DURATION VARIANCE SUMMARY 
-- Business question : 
-- On average, how does actual shipping duration compare with scheduled shipping duration?

-- Positive variance = slower than scheduled 
-- Zero variance = exactly on schedule 
-- Negative variance = faster than scheduled 

SELECT 
    COUNT(*) AS total_order_items, 
    ROUND(AVG(`Shipping Duration Variance`), 2) AS average_duration_variance_days, 
    MIN(`Shipping Duration Variance`) AS minimum_duration_variance_days, 
    MAX(`Shipping Duration Variance`) AS maximum_duration_variance_days, 
    SUM(
        CASE 
            WHEN `Shipping Duration Variance` > 0 THEN 1 
            ELSE 0 
        END 
    ) AS slower_than_scheduled_items, 
    SUM(
        CASE 
            WHEN `Shipping Duration Variance` = 0 THEN 1 
            ELSE 0 
        END 
    ) AS on_schedule_items, 
    SUM(
        CASE 
            WHEN `Shipping Duration Variance` < 0 THEN 1 
            ELSE 0 
        END 
    ) AS faster_than_scheduled_items 
FROM supply_chain_orders ; 

-- 5. SHIPPING PERFORMANCE DISTRIBUTION
-- Business question:
-- What proportion of order items were slower, on schedule, or faster than scheduled?
-- This uses the calculated Shipping Performance column.

WITH PerformanceCounts AS (
    SELECT 
        `Shipping Performance` AS shipping_performance, 
        COUNT(*) AS order_item_count, 
        SUM(COUNT(*)) OVER () AS total_dataset_items 
    FROM supply_chain_orders 
    GROUP BY `Shipping Performance` 
) 
SELECT 
    shipping_performance, 
    order_item_count, 
    ROUND(100.0 * order_item_count / NULLIF(total_dataset_items, 0), 2) AS percentage_of_order_items 
FROM PerformanceCounts 
ORDER BY order_item_count DESC ; 

-- 6. DELIVERY STATUS VS SHIPPING PERFORMANCE
-- Business question:
-- How do the dataset's delivery labels compare with the performance calculated from actual versus scheduled days?

WITH ReconciliationCounts AS (
    SELECT 
        `Delivery Status` AS delivery_status, 
        `Shipping Performance` AS shipping_performance, 
        COUNT(*) AS order_item_count, 
        SUM(COUNT(*)) OVER () AS total_dataset_items 
    FROM supply_chain_orders 
    GROUP BY `Delivery Status`, `Shipping Performance` 
) 
SELECT 
    delivery_status, 
    shipping_performance, 
    order_item_count, 
    ROUND(100.0 * order_item_count / NULLIF(total_dataset_items, 0), 2) AS percentage_of_all_order_items 
FROM ReconciliationCounts 
ORDER BY delivery_status, order_item_count DESC ; 


/* SHIPPING MODE ANALYSIS 
OBJECTIVE:
Compare delivery performance across shipping modes.
*/

-- 1. ORDER VOLUME BY SHIPPING MODE
-- Business question:
-- How much order-item volume does each shipping mode handle?

WITH ModeVolume AS (
    SELECT 
        `Shipping Mode` AS shipping_mode, 
        COUNT(*) AS total_order_items, 
        COUNT(DISTINCT `Order Id`) AS distinct_orders, 
        SUM(COUNT(*)) OVER () AS total_dataset_items 
    FROM supply_chain_orders 
    GROUP BY `Shipping Mode` 
) 
SELECT 
    shipping_mode, 
    total_order_items, 
    distinct_orders, 
    ROUND(100.0 * total_order_items / NULLIF(total_dataset_items, 0), 2) AS percentage_of_all_order_items 
FROM ModeVolume 
ORDER BY total_order_items DESC ; 

-- 2. LATE DELIVERY RATE BY SHIPPING MODE
-- Business question:
-- Which shipping modes have higher dataset-defined late delivery rates?

WITH ModeLateRates AS (
    SELECT 
        `Shipping Mode` AS shipping_mode, 
        COUNT(*) AS total_order_items, 
        SUM(CASE WHEN `Delivery Status` = 'Late delivery' THEN 1 ELSE 0 END) AS late_order_items 
    FROM supply_chain_orders 
    GROUP BY `Shipping Mode` 
) 
SELECT 
    shipping_mode, 
    total_order_items, 
    late_order_items, 
    ROUND(100.0 * late_order_items / NULLIF(total_order_items, 0), 2) AS late_delivery_rate_pct 
FROM ModeLateRates 
ORDER BY late_delivery_rate_pct DESC ; 

-- 3. ACTUAL VS SCHEDULED SHIPPING DURATION BY MODE
-- Business question:
-- Which shipping modes have the greatest average difference between actual and scheduled shipping days?
-- Positive average = slower than scheduled on average
-- Zero average    = matches schedule on average
-- Negative average = faster than scheduled on average

SELECT 
    `Shipping Mode` AS shipping_mode, 
    COUNT(*) AS total_order_items, 
    ROUND(AVG(`Days for shipping (real)`), 2) 
		AS avg_actual_shipping_days, 
    ROUND(AVG(`Days for shipment (scheduled)`), 2) 
		AS avg_scheduled_shipping_days, 
    ROUND(AVG(`Shipping Duration Variance`), 2) 
		AS avg_duration_variance_days 
FROM supply_chain_orders 
GROUP BY `Shipping Mode` 
ORDER BY avg_duration_variance_days DESC ; 

-- 4. SHIPPING PERFORMANCE DISTRIBUTION BY MODE
-- Business question:
-- Within each shipping mode, what percentage of order items were slower, on schedule, or faster than scheduled?
-- Percentages use each mode's own order-item count as the denominator, allowing a fair comparison across modes.

WITH ModePerformanceBreakdown AS (
    SELECT 
        `Shipping Mode` AS shipping_mode, 
        `Shipping Performance` AS shipping_performance, 
        COUNT(*) AS order_item_count, 
        SUM(COUNT(*)) OVER (PARTITION BY `Shipping Mode`) AS total_mode_items 
    FROM supply_chain_orders 
    GROUP BY `Shipping Mode`, `Shipping Performance` 
) 
SELECT 
    shipping_mode, 
    shipping_performance, 
    order_item_count, 
    ROUND(100.0 * order_item_count / NULLIF(total_mode_items, 0), 2) AS percentage_within_shipping_mode 
FROM ModePerformanceBreakdown 
ORDER BY shipping_mode, order_item_count DESC ; 

-- 5. SHIPPING MODE PERFORMANCE SUMMARY
-- Business question:
-- What proportion of each mode's order items were slower than scheduled, on schedule, or faster than scheduled?

WITH ShippingModeTotals AS (
    SELECT 
        `Shipping Mode` AS shipping_mode, 
        COUNT(*) AS total_order_items, 
        SUM(CASE WHEN `Shipping Duration Variance` > 0 THEN 1 ELSE 0 END) AS slower_than_scheduled_items, 
        SUM(CASE WHEN `Shipping Duration Variance` = 0 THEN 1 ELSE 0 END) AS on_schedule_items, 
        SUM(CASE WHEN `Shipping Duration Variance` < 0 THEN 1 ELSE 0 END) AS faster_than_scheduled_items 
    FROM supply_chain_orders 
    GROUP BY `Shipping Mode` 
) 
SELECT 
    shipping_mode, 
    total_order_items, 
    slower_than_scheduled_items, 
    ROUND(100.0 * slower_than_scheduled_items / NULLIF(total_order_items, 0), 2) AS slower_than_scheduled_pct, 
    on_schedule_items, 
    ROUND(100.0 * on_schedule_items / NULLIF(total_order_items, 0), 2) AS on_schedule_pct, 
    faster_than_scheduled_items, 
    ROUND(100.0 * faster_than_scheduled_items / NULLIF(total_order_items, 0), 2) AS faster_than_scheduled_pct 
FROM ShippingModeTotals 
ORDER BY slower_than_scheduled_pct DESC ; 


/* GEOGRAPHIC PERFORMANCE 
PURPOSE: Evaluate geographic delivery performance and risk
*/ 

-- 1: REGIONAL DELIVERY PERFORMANCE
-- Business question:
-- Which regions have the highest dataset-defined late delivery rates?

WITH regional_delivery AS (
    SELECT 
        `Order Region`, 
        COUNT(*) AS total_order_items, 
        COUNT(DISTINCT `Order Id`) AS total_distinct_orders, 
        SUM(
            CASE 
                WHEN `Delivery Status` = 'Late delivery' 
                THEN 1 ELSE 0 
            END 
        ) AS late_delivery_items 
    FROM supply_chain_orders 
    GROUP BY `Order Region` 
) 
SELECT 
    `Order Region`, 
    total_order_items, 
    total_distinct_orders, 
    late_delivery_items, 
    ROUND(100.0 * late_delivery_items / total_order_items, 2) AS late_delivery_rate_pct 
FROM regional_delivery 
ORDER BY late_delivery_rate_pct DESC ; 

-- 2: REGIONAL SHIPPING DURATION PERFORMANCE
-- Business question:
-- Which regions have the greatest average delay relative to their scheduled shipping duration?
-- Negative variance means faster than scheduled; positive variance means slower than scheduled.

WITH regional_shipping AS (
    SELECT 
        `Order Region`, 
        COUNT(*) AS total_order_items, 
        AVG(`Shipping Duration Variance`) AS avg_shipping_variance_days, 
        SUM(
            CASE 
                WHEN `Shipping Performance` = 'Slower than scheduled' 
                THEN 1 ELSE 0 
            END 
        ) AS slower_items, 
        SUM(
            CASE 
                WHEN `Shipping Performance` = 'On schedule' 
                THEN 1 ELSE 0 
            END 
        ) AS on_schedule_items, 
        SUM(
            CASE 
                WHEN `Shipping Performance` = 'Faster than scheduled' 
                THEN 1 ELSE 0 
            END 
        ) AS faster_items 
    FROM supply_chain_orders 
    GROUP BY `Order Region` 
) 
SELECT 
    `Order Region`, 
    total_order_items, 
    ROUND(avg_shipping_variance_days, 2) AS avg_shipping_variance_days, 
    slower_items, 
    ROUND(100.0 * slower_items / total_order_items, 2) AS slower_than_scheduled_pct, 
    on_schedule_items, 
    faster_items 
FROM regional_shipping 
ORDER BY avg_shipping_variance_days DESC ; 

-- 3: COUNTRY-LEVEL DELIVERY RISK
-- Business question:
-- Which countries have high late-delivery rates among countries with sufficient order-item volume?
-- Minimum volume threshold: 100 order items. This reduces emphasis on very small samples.

WITH country_delivery AS (
    SELECT 
        `Order Country`, 
        COUNT(*) AS total_order_items, 
        COUNT(DISTINCT `Order Id`) AS total_orders, 
        SUM(
            CASE 
                WHEN `Delivery Status` = 'Late delivery' 
                THEN 1 ELSE 0 
            END 
        ) AS late_delivery_items, 
        AVG(`Shipping Duration Variance`) AS avg_shipping_variance_days 
    FROM supply_chain_orders 
    GROUP BY `Order Country` 
) 
SELECT 
    `Order Country`, 
    total_order_items, 
    total_orders, 
    late_delivery_items, 
    ROUND(100.0 * late_delivery_items / total_order_items, 2) AS late_delivery_rate_pct, 
    ROUND(avg_shipping_variance_days, 2) AS avg_shipping_variance_days 
FROM country_delivery 
WHERE total_order_items >= 100 
ORDER BY late_delivery_rate_pct DESC ; 

-- 4: DELIVERY STATUS MIX WITHIN EACH REGION
-- Business question:
-- What proportion of each region's order items falls into each delivery status?

WITH regional_status_counts AS (
    SELECT 
        `Order Region`, 
        `Delivery Status`, 
        COUNT(*) AS order_item_count 
    FROM supply_chain_orders 
    GROUP BY 
        `Order Region`, 
        `Delivery Status` 
) 
SELECT 
    `Order Region`, 
    `Delivery Status`, 
    order_item_count, 
    SUM(order_item_count) OVER (PARTITION BY `Order Region`) AS regional_total_items, 
    ROUND(100.0 * order_item_count / SUM(order_item_count) OVER (PARTITION BY `Order Region`), 2) 
		AS pct_within_region 
FROM regional_status_counts 
ORDER BY `Order Region`, order_item_count DESC ; 


/* PRODUCT CATEGORY ANALYSIS 
-- PURPOSE: Analyze product and category performance
*/

-- 1: PRODUCT CATEGORY PERFORMANCE
-- Business question:
-- Which categories contribute the most sales, profit, and order-item volume?

WITH category_performance AS ( 
    SELECT 
        `Category Name`, 
        COUNT(*) AS total_order_items, 
        COUNT(DISTINCT `Order Id`) AS total_orders, 
        SUM(`Order Item Quantity`) AS total_units, 
        SUM(Sales) AS total_sales, 
        SUM(`Order Profit Per Order`) AS total_profit, 
        AVG(`Order Item Profit Ratio`) AS avg_profit_ratio 
    FROM supply_chain_orders 
    GROUP BY `Category Name` 
) 
SELECT 
    `Category Name`, 
    total_order_items, 
    total_orders, 
    total_units, 
    ROUND(total_sales, 2) AS total_sales, 
    ROUND(total_profit, 2) AS total_profit, 
    ROUND(avg_profit_ratio, 4) AS avg_profit_ratio 
FROM category_performance
ORDER BY total_sales DESC ; 

-- 2: TOP PRODUCTS BY SALES AND PROFIT
-- Business question:
-- Which products rank highest by sales and profit?

WITH product_performance AS (
    SELECT 
        `Product Card Id`, 
        `Product Name`, 
        `Category Name`, 
        COUNT(*) AS total_order_items, 
        SUM(`Order Item Quantity`) AS total_units, 
        SUM(Sales) AS total_sales, 
        SUM(`Order Profit Per Order`) AS total_profit 
    FROM supply_chain_orders 
    GROUP BY `Product Card Id`, `Product Name`, `Category Name` 
), 
ranked_products AS (
    SELECT 
        *, 
        DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank, 
        DENSE_RANK() OVER (ORDER BY total_profit DESC ) AS profit_rank 
    FROM product_performance 
) 
SELECT 
    `Product Card Id`, 
    `Product Name`, 
    `Category Name`, 
    total_order_items, 
    total_units, 
    ROUND(total_sales, 2) AS total_sales, 
    ROUND(total_profit, 2) AS total_profit, 
    sales_rank, 
    profit_rank 
FROM ranked_products 
WHERE sales_rank <= 10 
   OR profit_rank <= 10 
ORDER BY sales_rank, profit_rank ; 

-- 3: CATEGORY-LEVEL UNIT AND PROFIT METRICS
-- Business question:
-- How do categories compare in units sold, average quantity per order item, and average profit per order item?

SELECT 
    `Category Name`, 
    COUNT(*) AS total_order_items, 
    SUM(`Order Item Quantity`) AS total_units, 
    ROUND(AVG(`Order Item Quantity`), 2) AS avg_quantity_per_item, 
    ROUND(AVG(`Order Profit Per Order`), 2) AS avg_profit_per_order_item, 
    ROUND(AVG(Sales), 2) AS avg_sales_per_order_item 
FROM supply_chain_orders 
GROUP BY `Category Name` 
ORDER BY avg_profit_per_order_item DESC ; 

-- 4: CATEGORY CONTRIBUTION TO TOTAL SALES AND PROFIT
-- Business question:
-- What percentage of total sales and profit is associated with each product category?

WITH category_totals AS (
    SELECT 
        `Category Name`, 
        SUM(Sales) AS total_sales, 
        SUM(`Order Profit Per Order`) AS total_profit 
    FROM supply_chain_orders 
    GROUP BY `Category Name` 
) 
SELECT 
    `Category Name`, 
    ROUND(total_sales, 2) AS total_sales, 
    ROUND(100.0 * total_sales / SUM(total_sales) OVER (), 2) AS sales_contribution_pct, 
    ROUND(total_profit, 2) AS total_profit, 
    ROUND(100.0 * total_profit / SUM(total_profit) OVER (), 2) AS profit_contribution_pct 
FROM category_totals 
ORDER BY total_sales DESC ; 


/* VOLUME VS RELIABILITY 
OBJECTIVE:
Analyze the relationship between order-item volume and
shipping reliability across operational dimensions.
*/ 

-- 1: Order-item volume and delivery reliability
-- Group orders into order-item volume bands.

WITH order_volume AS ( 
    SELECT 
        `Order Id`, 
        COUNT(*) AS order_item_count, 
        MAX(
            CASE 
                WHEN `Delivery Status` = 'Late delivery' THEN 1 
                ELSE 0 
            END 
        ) AS has_late_delivery 
    FROM supply_chain_orders 
    GROUP BY `Order Id` 
), 
volume_bands AS ( 
    SELECT 
        `Order Id`, 
        order_item_count, 
        has_late_delivery, 
        CASE 
            WHEN order_item_count = 1 THEN '01 - Single item' 
            WHEN order_item_count BETWEEN 2 AND 3 THEN '02 - 2 to 3 items' 
            WHEN order_item_count BETWEEN 4 AND 6 THEN '03 - 4 to 6 items' 
            ELSE '04 - 7+ items' 
        END AS order_volume_band 
    FROM order_volume 
) 
SELECT 
    order_volume_band, 
    COUNT(*) AS total_orders, 
    SUM(order_item_count) AS total_order_items, 
    ROUND(AVG(order_item_count), 2) AS avg_items_per_order, 
    SUM(has_late_delivery) AS orders_with_late_items, 
    ROUND(100.0 * SUM(has_late_delivery) / COUNT(*), 2) AS pct_orders_with_late_items 
FROM volume_bands 
GROUP BY order_volume_band 
ORDER BY order_volume_band ; 

-- follow-up query for checking 7+ order items
SELECT 
    COUNT(*) AS orders_with_7plus_items, 
    SUM(order_item_count) AS order_items_in_7plus_orders 
FROM (
    SELECT 
        `Order Id`, 
        COUNT(*) AS order_item_count 
    FROM supply_chain_orders 
    GROUP BY `Order Id` 
    HAVING COUNT(*) >= 7 
) AS large_orders ; 

-- 2: Volume and delivery performance by shipping mode
-- Uses the dataset-defined Delivery Status measure.

WITH mode_volume AS ( 
    SELECT 
        `Shipping Mode`, 
        COUNT(*) AS total_order_items, 
        COUNT(DISTINCT `Order Id`) AS total_orders, 
        SUM( 
            CASE 
                WHEN `Delivery Status` = 'Late delivery' THEN 1 
                ELSE 0 
            END 
        ) AS late_order_items 
    FROM supply_chain_orders 
    GROUP BY `Shipping Mode` 
) 
SELECT 
    `Shipping Mode`, 
    total_order_items, 
    total_orders, 
    ROUND(100.0 * total_order_items / SUM(total_order_items) OVER (), 2) AS item_volume_share_pct, 
    late_order_items, 
    ROUND(100.0 * late_order_items / total_order_items, 2) AS late_delivery_rate_pct 
FROM mode_volume 
ORDER BY total_order_items DESC ; 

-- 3: Volume and shipping reliability by region
-- Compare order-item volume with slower-than-scheduled rate.

WITH regional_volume AS ( 
    SELECT 
        `Order Region`, 
        COUNT(*) AS total_order_items, 
        COUNT(DISTINCT `Order Id`) AS total_orders, 
        SUM(
            CASE 
                WHEN `Shipping Duration Variance` > 0 THEN 1 
                ELSE 0 
            END 
        ) AS slower_than_scheduled_items, 
        AVG(`Shipping Duration Variance`) AS avg_duration_variance 
    FROM supply_chain_orders 
    GROUP BY `Order Region` 
) 
SELECT 
    `Order Region`, 
    total_order_items, 
    total_orders, 
    ROUND(100.0 * total_order_items / SUM(total_order_items) OVER (), 2) AS item_volume_share_pct, 
    slower_than_scheduled_items, 
    ROUND(100.0 * slower_than_scheduled_items / total_order_items, 2) AS slower_than_scheduled_pct, 
    ROUND(avg_duration_variance, 2) AS avg_duration_variance_days 
FROM regional_volume 
ORDER BY total_order_items DESC ; 

-- 4: Order-item volume and shipping duration variance
-- Examine whether larger orders have different shipping outcomes.

WITH order_volume AS ( 
    SELECT 
        `Order Id`, 
        COUNT(*) AS order_item_count 
    FROM supply_chain_orders 
    GROUP BY `Order Id` 
), 
order_item_performance AS ( 
    SELECT 
        s.`Order Id`, 
        ov.order_item_count, 
        s.`Shipping Duration Variance`, 
        CASE 
            WHEN s.`Shipping Duration Variance` > 0 THEN 1 
            ELSE 0 
        END AS slower_than_scheduled_flag
    FROM supply_chain_orders AS s 
    INNER JOIN order_volume AS ov 
        ON s.`Order Id` = ov.`Order Id` 
) 
SELECT 
    CASE 
        WHEN order_item_count = 1 THEN '01 - Single item' 
        WHEN order_item_count BETWEEN 2 AND 3 THEN '02 - 2 to 3 items' 
        WHEN order_item_count BETWEEN 4 AND 6 THEN '03 - 4 to 6 items' 
        ELSE '04 - 7+ items' 
    END AS order_volume_band, 
    COUNT(*) AS total_order_items, 
    COUNT(DISTINCT `Order Id`) AS total_orders, 
    ROUND(AVG(`Shipping Duration Variance`), 2) AS avg_duration_variance_days, 
    SUM(slower_than_scheduled_flag) AS slower_than_scheduled_items, 
    ROUND(100.0 * SUM(slower_than_scheduled_flag) / COUNT(*), 2) AS slower_than_scheduled_pct 
FROM order_item_performance 
GROUP BY 
    CASE 
        WHEN order_item_count = 1 THEN '01 - Single item' 
        WHEN order_item_count BETWEEN 2 AND 3 THEN '02 - 2 to 3 items' 
        WHEN order_item_count BETWEEN 4 AND 6 THEN '03 - 4 to 6 items' 
        ELSE '04 - 7+ items' 
    END 
ORDER BY order_volume_band ; 


/* TIME TREND ANALYSIS 

PURPOSE
1. Analyze monthly order-item volume and delivery performance.
2. Compare monthly delivery-status distribution.
3. Diagnose changes in monthly order and item characteristics.

IMPORTANT
- Dataset grain: one row per order item.
- Late delivery and slower-than-scheduled are separate measures.
- Monthly volume changes after September 2017 require investigation.
*/

-- 1: MONTHLY DELIVERY AND SHIPPING PERFORMANCE TRENDS

WITH monthly_performance AS (
    SELECT 
        `Order Year`, 
        `Order Month`, 
        MIN(`Order Date Only`) AS month_start_date,
        COUNT(*) AS total_order_items, 
        COUNT(DISTINCT `Order Id`) AS total_orders, 
        SUM(
            CASE 
                WHEN `Delivery Status` = 'Late delivery' 
                THEN 1 ELSE 0 
            END 
        ) AS late_order_items, 
        SUM(
            CASE 
                WHEN `Shipping Duration Variance` > 0 
                THEN 1 ELSE 0 
            END 
        ) AS slower_than_scheduled_items, 
        AVG(`Shipping Duration Variance`) 
            AS avg_duration_variance_days 
    FROM supply_chain_orders 
    GROUP BY `Order Year`, `Order Month` 
), 
monthly_with_previous AS (
    SELECT 
        *, 
        LAG(total_order_items) OVER (ORDER BY month_start_date) 
			AS previous_month_items, 
        LAG(100.0 * late_order_items / NULLIF(total_order_items, 0)) OVER (
            ORDER BY month_start_date) AS previous_month_late_rate_pct, 
        LAG(100.0 * slower_than_scheduled_items / NULLIF(total_order_items, 0)) OVER (
            ORDER BY month_start_date) AS previous_month_slower_rate_pct, 
        LAG(avg_duration_variance_days) OVER (ORDER BY month_start_date) AS previous_month_avg_variance_days 
    FROM monthly_performance 
) 
SELECT 
    `Order Year` AS order_year, 
    `Order Month` AS order_month, 
    month_start_date, 
    total_order_items, 
    total_orders, 
    ROUND(100.0 * total_order_items / SUM(total_order_items) OVER (), 2) AS item_volume_share_pct, 
    previous_month_items, 
    ROUND(100.0 * (total_order_items - previous_month_items) / NULLIF(previous_month_items, 0), 2) 
		AS item_volume_change_pct, 
    late_order_items, 
    ROUND(100.0 * late_order_items / NULLIF(total_order_items, 0), 2) 
		AS late_delivery_rate_pct, 
    ROUND(previous_month_late_rate_pct, 2)
        AS previous_month_late_rate_pct, 
    ROUND(100.0 * late_order_items / NULLIF(total_order_items, 0) - previous_month_late_rate_pct, 2) 
		AS late_rate_change_pp, 
    slower_than_scheduled_items, 
    ROUND(100.0 * slower_than_scheduled_items / NULLIF(total_order_items, 0), 2) 
		AS slower_than_scheduled_pct, 
    ROUND(previous_month_slower_rate_pct, 2)
        AS previous_month_slower_rate_pct, 
    ROUND(100.0 * slower_than_scheduled_items / NULLIF(total_order_items, 0) - previous_month_slower_rate_pct, 2) 
		AS slower_rate_change_pp, 
    ROUND(avg_duration_variance_days, 2) AS avg_duration_variance_days, 
    ROUND(avg_duration_variance_days - previous_month_avg_variance_days, 2) AS avg_variance_change_days 
FROM monthly_with_previous 
ORDER BY month_start_date ; 

-- 2: MONTHLY DELIVERY-STATUS DISTRIBUTION

WITH monthly_status AS (
    SELECT 
        `Order Year` AS order_year, 
        `Order Month` AS order_month, 
        STR_TO_DATE(
            CONCAT(
                `Order Year`, '-',
                LPAD(`Order Month`, 2, '0'),
                '-01'
            ), 
            '%Y-%m-%d'
        ) AS month_start_date, 
        `Delivery Status` AS delivery_status,
        COUNT(*) AS status_order_items
    FROM supply_chain_orders 
    GROUP BY `Order Year`, `Order Month`, `Delivery Status`
) 
SELECT
    order_year,
    order_month,
    month_start_date,
    delivery_status,
    status_order_items,
    SUM(status_order_items) OVER (PARTITION BY order_year, order_month) AS monthly_total_items,
    ROUND(100.0 * status_order_items / NULLIF(
            SUM(status_order_items) OVER (
                PARTITION BY order_year, order_month
            ),
            0
        ),
        2
    ) AS monthly_status_share_pct
FROM monthly_status
ORDER BY month_start_date, status_order_items DESC ; 

-- 3: MONTHLY VOLUME AND ORDER CHARACTERISTICS
-- DIAGNOSTIC — INVESTIGATE THE CHANGE AFTER SEPTEMBER 2017

SELECT
    `Order Year` AS order_year,
    `Order Month` AS order_month,
    MIN(`Order Date Only`) AS month_start_date,
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT `Order Id`) AS total_orders,
    COUNT(DISTINCT `Order Customer Id`) AS unique_customers,
    COUNT(DISTINCT `Product Card Id`) AS unique_products,
    SUM(`Order Item Quantity`) AS total_units,
    ROUND(AVG(`Order Item Quantity`), 2) AS avg_units_per_item, 
    ROUND(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT `Order Id`), 0), 2) 
		AS avg_items_per_order 
FROM supply_chain_orders 
GROUP BY `Order Year`, `Order Month` 
ORDER BY `Order Year`, `Order Month` ; 

/* 
INTERPRETATION REMINDER :
The source data changes structurally from October 2017.
The cause has not been established. 
 */


/* FINANCIAL EXPOSURE ANALYSIS 

PURPOSE
1. Quantify sales and profit associated with delayed shipments.
2. Compare financial exposure across shipping modes.
3. Identify geographic differences in delayed-shipment exposure.
4. Identify product categories with the highest delayed-shipment exposure.

IMPORTANT
- Dataset grain: one row per order item.
- Delayed Sales and Delayed Profit are exposure measures,
  not estimates of lost sales or lost profit.
- Use the existing cleaned flags and financial columns.
- Results describe associations, not causes.
*/

-- 1: OVERALL FINANCIAL EXPOSURE

SELECT 
    COUNT(*) AS total_order_items,
    SUM(`Delayed Shipment Flag`) AS delayed_order_items,
    ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2) 
		AS delayed_item_rate_pct,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(`Order Profit Per Order`), 2) AS total_order_profit,
    ROUND(SUM(`Delayed Sales`), 2) AS sales_associated_with_delayed_shipments,
    ROUND(SUM(`Delayed Profit`), 2) AS profit_associated_with_delayed_shipments,
    ROUND(100.0 * SUM(`Delayed Sales`) / NULLIF(SUM(Sales), 0), 2) 
		AS delayed_sales_share_pct
FROM supply_chain_orders ;

-- 2: FINANCIAL EXPOSURE BY SHIPPING MODE

SELECT 
    `Shipping Mode` AS shipping_mode,
    COUNT(*) AS total_order_items,
    SUM(`Delayed Shipment Flag`) AS delayed_order_items,
    ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2) 
		AS delayed_item_rate_pct,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(`Delayed Sales`), 2) AS delayed_shipment_sales,
    ROUND(100.0 * SUM(`Delayed Sales`) / NULLIF(SUM(Sales), 0), 2) 
		AS delayed_sales_share_pct,
    ROUND(SUM(`Delayed Profit`), 2) AS delayed_shipment_profit
FROM supply_chain_orders 
GROUP BY `Shipping Mode`
ORDER BY delayed_shipment_sales DESC ; 

-- 3: FINANCIAL EXPOSURE BY ORDER REGION

SELECT 
    `Order Region` AS order_region,
    COUNT(*) AS total_order_items, 
    SUM(`Delayed Shipment Flag`) AS delayed_order_items, 
    ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2) 
		AS delayed_item_rate_pct,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(`Delayed Sales`), 2) AS delayed_shipment_sales,
    ROUND(100.0 * SUM(`Delayed Sales`) / NULLIF(SUM(Sales), 0), 2) 
		AS delayed_sales_share_pct,
    ROUND(SUM(`Delayed Profit`), 2) AS delayed_shipment_profit
FROM supply_chain_orders 
GROUP BY `Order Region`
ORDER BY delayed_shipment_sales DESC ; 

-- 4: FINANCIAL EXPOSURE BY PRODUCT CATEGORY

SELECT 
    `Category Name` AS product_category,
    COUNT(*) AS total_order_items,
    SUM(`Delayed Shipment Flag`) AS delayed_order_items,
    ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2)
		AS delayed_item_rate_pct, 
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(`Delayed Sales`), 2) AS delayed_shipment_sales, 
    ROUND(100.0 * SUM(`Delayed Sales`)/ NULLIF(SUM(Sales), 0), 2) 
		AS delayed_sales_share_pct,
    ROUND(SUM(`Delayed Profit`), 2) AS delayed_shipment_profit
FROM supply_chain_orders
GROUP BY `Category Name`
ORDER BY delayed_shipment_sales DESC ;


/* FINAL BUSINESS INSIGHTS 

PURPOSE
1. Produce a final executive KPI scorecard.
2. Rank shipping modes by delayed-shipment sales exposure.
3. Identify geographic areas with high delay rates and exposure.
4. Rank product categories by exposure while flagging small samples.

INTERPRETATION
- Dataset grain: one row per order item.
- Delay measures use the existing cleaned fields.
- Financial exposure is not equivalent to lost revenue or profit.
- Observed patterns do not establish causation.
*/

-- 1: EXECUTIVE KPI SCORECARD
SELECT
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT `Order Id`) AS total_orders,
    COUNT(DISTINCT `Order Customer Id`) AS unique_customers,
    COUNT(DISTINCT `Product Card Id`) AS unique_products,
    SUM(
        CASE
            WHEN `Delivery Status` = 'Late delivery'
            THEN 1 ELSE 0
        END
    ) AS late_delivery_status_items,
    ROUND(100.0 * SUM(
		CASE
			WHEN `Delivery Status` = 'Late delivery'
			THEN 1 ELSE 0
		END
	) / NULLIF(COUNT(*), 0), 2) AS late_delivery_status_rate_pct,
    SUM(`Delayed Shipment Flag`) AS slower_than_scheduled_items,
    ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2) 
		AS slower_than_scheduled_rate_pct,
    ROUND(AVG(`Shipping Duration Variance`), 2)
        AS avg_shipping_duration_variance_days,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(`Delayed Sales`), 2) AS sales_associated_with_delayed_shipments,
    ROUND(100.0 * SUM(`Delayed Sales`) / NULLIF(SUM(Sales), 0), 2) 
		AS delayed_shipment_sales_share_pct,
    ROUND(SUM(`Delayed Profit`), 2) AS profit_associated_with_delayed_shipments
FROM supply_chain_orders ; 

-- 2: SHIPPING MODES RANKED BY FINANCIAL EXPOSURE

WITH shipping_mode_metrics AS (
    SELECT
        `Shipping Mode` AS shipping_mode,
        COUNT(*) AS total_order_items,
        SUM(`Delayed Shipment Flag`) AS slower_than_scheduled_items,
        ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2) 
			AS slower_than_scheduled_rate_pct,
        ROUND(SUM(`Delayed Sales`), 2) AS delayed_shipment_sales,
        ROUND(SUM(`Delayed Profit`), 2) AS delayed_shipment_profit
    FROM supply_chain_orders
    GROUP BY `Shipping Mode`
)
SELECT
    shipping_mode,
    total_order_items,
    slower_than_scheduled_items,
    slower_than_scheduled_rate_pct,
    delayed_shipment_sales,
    delayed_shipment_profit,
    DENSE_RANK() OVER (ORDER BY delayed_shipment_sales DESC) 
		AS delayed_sales_exposure_rank
FROM shipping_mode_metrics
ORDER BY delayed_sales_exposure_rank ; 

-- 3: GEOGRAPHIC RISK AND FINANCIAL EXPOSURE

WITH regional_metrics AS (
    SELECT
        `Order Region` AS order_region,
        COUNT(*) AS total_order_items,
        SUM(`Delayed Shipment Flag`) AS slower_than_scheduled_items,
        ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2) 
			AS slower_than_scheduled_rate_pct,
        ROUND(SUM(`Delayed Sales`), 2) AS delayed_shipment_sales,
        ROUND(SUM(`Delayed Profit`), 2) AS delayed_shipment_profit
    FROM supply_chain_orders 
    GROUP BY `Order Region`
)
SELECT
    order_region,
    total_order_items,
    slower_than_scheduled_items,
    slower_than_scheduled_rate_pct,
    delayed_shipment_sales,
    delayed_shipment_profit,
    DENSE_RANK() OVER (ORDER BY delayed_shipment_sales DESC) 
		AS financial_exposure_rank,
    DENSE_RANK() OVER (ORDER BY slower_than_scheduled_rate_pct DESC) 
		AS delay_rate_rank
FROM regional_metrics
ORDER BY financial_exposure_rank ;

-- 4: PRODUCT CATEGORIES TO INVESTIGATE
-- Excludes categories with fewer than 100 items from ranking. Retains all categories in the output for transparency.

WITH category_metrics AS (
    SELECT
        `Category Name` AS product_category,
        COUNT(*) AS total_order_items,
        SUM(`Delayed Shipment Flag`) AS slower_than_scheduled_items,
        ROUND(100.0 * SUM(`Delayed Shipment Flag`) / NULLIF(COUNT(*), 0), 2) 
			AS slower_than_scheduled_rate_pct,
        ROUND(SUM(Sales), 2) AS total_sales, 
        ROUND(SUM(`Delayed Sales`), 2) AS delayed_shipment_sales,
        ROUND(SUM(`Delayed Profit`), 2) AS delayed_shipment_profit
    FROM supply_chain_orders 
    GROUP BY `Category Name`
),
ranked_categories AS (
    SELECT
        *,
        CASE
            WHEN total_order_items < 100
                THEN 'Small sample'
            ELSE 'Eligible for ranking'
        END AS sample_size_note,
        CASE
            WHEN total_order_items >= 100 THEN
                DENSE_RANK() OVER (
                    PARTITION BY
                        CASE
                            WHEN total_order_items >= 100 THEN 1
                            ELSE 0
                        END
                    ORDER BY delayed_shipment_sales DESC
                )
            ELSE NULL
        END AS delayed_sales_exposure_rank
    FROM category_metrics
)
SELECT
    product_category,
    total_order_items,
    slower_than_scheduled_items,
    slower_than_scheduled_rate_pct,
    total_sales,
    delayed_shipment_sales,
    delayed_shipment_profit,
    sample_size_note,
    delayed_sales_exposure_rank
FROM ranked_categories
ORDER BY
    CASE
        WHEN sample_size_note = 'Eligible for ranking' THEN 0
        ELSE 1
    END,
    delayed_sales_exposure_rank,
    total_order_items DESC ; 
