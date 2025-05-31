-- Task 2_2: Top 5 Most-Ordered Products per Country
WITH
  -- 1) Filter out bad rows & parse dates
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

  -- 2) Deduplicate exact repeats
  deduped_orders AS (
    SELECT DISTINCT
      order_id,
      country_iso,
      product_number,
      order_date
    FROM
      raw_orders
  ),

  -- 3) Enrich with product category, bucket nulls as 'Unknown'
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

  -- 4) Count orders per product per country
  product_stats AS (
    SELECT
      country_iso,
      product_number,
      main_category,
      COUNT(*) AS order_count
    FROM
      enriched_orders
    GROUP BY
      country_iso,
      product_number,
      main_category
  ),

  -- 5) Rank descending by order_count
  ranked_desc AS (
    SELECT
      country_iso,
      product_number,
      main_category,
      order_count,
      RANK() OVER (
        PARTITION BY country_iso
        ORDER BY order_count DESC
      ) AS rank_desc
    FROM
      product_stats
  )

-- 6) Pull only the top-5 per country
SELECT
  country_iso,
  product_number,
  main_category,
  order_count
FROM
  ranked_desc
WHERE
  rank_desc <= 5
ORDER BY
  country_iso,
  rank_desc;
