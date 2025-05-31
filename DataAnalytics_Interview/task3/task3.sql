-- Task 3: First Orders & New Customer Share by Day 

WITH
  -- 1) Load and clean orders
  raw_orders AS (
    SELECT
      order_id,
      customer_id,
      SAFE_CAST(order_date AS DATE) AS order_date
    FROM
      `koro-461411.analytics_assessment.orders`
    WHERE
      order_id      IS NOT NULL
      AND customer_id IS NOT NULL
      AND order_date  IS NOT NULL
  ),

  -- 2) Remove exact duplicates
  deduped_orders AS (
    SELECT DISTINCT
      order_id,
      customer_id,
      order_date
    FROM
      raw_orders
  ),

  -- 3) Clean marketing_sources, pick one channel per order (fill NULL with 'Unknown')
  marketing_clean AS (
    SELECT
      order_id,
      COALESCE(
        ARRAY_AGG(reporting_channel IGNORE NULLS LIMIT 1)[OFFSET(0)],
        'Unknown'
      ) AS reporting_channel
    FROM
      `koro-461411.analytics_assessment.marketing`
    WHERE
      order_id IS NOT NULL
    GROUP BY
      order_id
  ),

  -- 4) Flag first orders per customer and attach channel
  flagged AS (
    SELECT
      o.order_date,
      o.customer_id,
      COALESCE(m.reporting_channel, 'Unknown') AS reporting_channel,
      ROW_NUMBER() OVER (
        PARTITION BY o.customer_id
        ORDER BY o.order_date ASC, o.order_id ASC
      ) AS rn
    FROM
      deduped_orders AS o
    LEFT JOIN
      marketing_clean AS m
    ON
      o.order_id = m.order_id
  ),

  -- 5a) Aggregate overall daily metrics
  overall AS (
    SELECT
      order_date,
      COUNT(*)            AS total_orders,
      COUNTIF(rn = 1)     AS first_orders,
      ROUND(
        SAFE_DIVIDE(COUNTIF(rn = 1), COUNT(*)) * 100,
        2
      )                   AS pct_new_customers
    FROM
      flagged
    GROUP BY
      order_date
  ),

  -- 5b) Aggregate daily metrics by channel
  by_channel AS (
    SELECT
      order_date,
      reporting_channel,
      COUNT(*)            AS total_orders,
      COUNTIF(rn = 1)     AS first_orders,
      ROUND(
        SAFE_DIVIDE(COUNTIF(rn = 1), COUNT(*)) * 100,
        2
      )                   AS pct_new_customers
    FROM
      flagged
    GROUP BY
      order_date,
      reporting_channel
  )

-- 6) Combine overall + channel breakdown into one result set
SELECT
  order_date,
  'Overall'           AS reporting_channel,
  total_orders,
  first_orders,
  pct_new_customers
FROM
  overall

UNION ALL

SELECT
  order_date,
  reporting_channel,
  total_orders,
  first_orders,
  pct_new_customers
FROM
  by_channel

ORDER BY
  order_date,
  reporting_channel;
