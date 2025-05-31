-- Task 1 
WITH
  -- 1) Clean & parse orders
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

  -- 2) Deduplicate orders
  deduped_orders AS (
    SELECT DISTINCT
      order_id,
      customer_id,
      order_date
    FROM
      raw_orders
  ),

  -- 3) First order date per customer
  first_order AS (
    SELECT
      customer_id,
      MIN(order_date) AS first_date
    FROM
      deduped_orders
    GROUP BY customer_id
  ),

  -- 4) Clean marketing, pick one channel (including nulls)
  marketing_clean AS (
    SELECT
      order_id,
      ARRAY_AGG(reporting_channel LIMIT 1)[OFFSET(0)]
        AS reporting_channel
    FROM
      `koro-461411.analytics_assessment.marketing`
    GROUP BY order_id
  ),

  -- 5) Attach days_since_first + raw channel
  orders_with_diff AS (
    SELECT
      o.customer_id,
      o.order_id,
      o.order_date,
      f.first_date,
      DATE_DIFF(o.order_date, f.first_date, DAY) AS days_since_first,
      m.reporting_channel
    FROM
      deduped_orders o
    JOIN
      first_order   f
    USING(customer_id)
    LEFT JOIN
      marketing_clean m
    ON
      o.order_id = m.order_id
  )

-- 6) Final aggregation, replacing NULL channel with 'Unknown'
SELECT
  f.customer_id,
  f.first_date,

  COALESCE(ow.reporting_channel, 'Unknown') AS reporting_channel,

  COUNTIF(ow.days_since_first BETWEEN 0 AND 10) AS orders_0_10d,
  COUNTIF(ow.days_since_first BETWEEN 0 AND 15) AS orders_0_15d,
  COUNTIF(ow.days_since_first BETWEEN 0 AND 20) AS orders_0_20d

FROM
  first_order    f
LEFT JOIN
  orders_with_diff ow
ON
  f.customer_id = ow.customer_id

GROUP BY
  f.customer_id,
  f.first_date,
  reporting_channel

ORDER BY
  f.first_date,
  reporting_channel;
