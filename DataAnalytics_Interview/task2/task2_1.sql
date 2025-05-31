-- Task 2_1: Total orders & SKUs by main_category

WITH
  -- 1) Parse & filter out bad rows
  raw_orders AS (
    SELECT
      order_id,
      country_iso,
      product_number,
      SAFE_CAST(order_date AS DATE) AS order_date
    FROM
      `koro-461411.analytics_assessment.orders`
    WHERE
      order_id        IS NOT NULL
      AND country_iso  IS NOT NULL
      AND product_number IS NOT NULL
      AND order_date   IS NOT NULL
  ),

  -- 2) Remove any exact duplicates
  deduped_orders AS (
    SELECT DISTINCT
      order_id,
      country_iso,
      product_number,
      order_date
    FROM
      raw_orders
  ),

  -- 3) Bring in main_category, bucketing NULLs as 'Unknown'
  enriched_orders AS (
    SELECT
      o.*,
      COALESCE(pu.main_category, 'Unknown') AS main_category
    FROM
      deduped_orders AS o
    LEFT JOIN
      `koro-461411.analytics_assessment.product_uni` AS pu
    ON
      o.product_number = pu.sku
  ),

  -- 4) Aggregate per country & category
  category_stats AS (
    SELECT
      country_iso,
      main_category,
      COUNT(1)                     AS total_orders,
      COUNT(DISTINCT product_number) AS total_skus
    FROM
      enriched_orders
    GROUP BY
      country_iso,
      main_category
  )

SELECT
  country_iso,
  main_category,
  total_orders,
  total_skus
FROM
  category_stats
ORDER BY
  country_iso,
  total_orders DESC;
