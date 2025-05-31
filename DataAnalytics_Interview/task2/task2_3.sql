-- Task 2_3: Bottom 5 Least-Ordered Products per Country 

WITH
  -- 1) Filter & parse dates
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

  -- 2) Deduplicate
  deduped_orders AS (
    SELECT DISTINCT
      order_id,
      country_iso,
      product_number,
      order_date
    FROM raw_orders
  ),

  -- 3) Enrich with category, bucket nulls
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

  -- 4) Count orders per product
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

  -- 5) Rank ascending by order_count, breaking ties by product_number
  ranked_asc AS (
    SELECT
      country_iso,
      product_number,
      main_category,
      order_count,
      RANK() OVER (
        PARTITION BY country_iso
        ORDER BY order_count ASC, product_number ASC
      ) AS rank_asc
    FROM product_stats
  )

-- 6) Select exactly five products per country
SELECT
  country_iso,
  product_number,
  main_category,
  order_count
FROM
  ranked_asc
WHERE
  rank_asc <= 5
ORDER BY
  country_iso,
  rank_asc;
