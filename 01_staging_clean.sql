-- ============================================================
-- 01_staging_clean.sql
-- Stage 1: Cleaning layer
-- Builds stg_events_clean from the raw GA4 public export.
--   • Removes missing data (no session id / no user id)
--   • Removes duplicate events
--   • Deduplicates orders (one purchase per transaction_id)
--   • Fills missing revenue with 0
-- Run this FIRST.
-- ============================================================

CREATE OR REPLACE TABLE `ecommerce-portfolio-451203.ga4_clean.stg_events_clean` AS

WITH extracted AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params)
       WHERE key = 'ga_session_id')                   AS ga_session_id,
    event_name,
    event_timestamp,
    PARSE_DATE('%Y%m%d', event_date)                  AS event_date,
    device.category                                   AS device_category,
    platform,
    traffic_source.source                             AS source,
    traffic_source.medium                             AS medium,
    geo.country                                       AS country,
    COALESCE(ecommerce.purchase_revenue_in_usd, 0)    AS revenue,   -- handle missing revenue
    ecommerce.transaction_id                          AS transaction_id,
    items
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'             -- date pruning = cheaper queries
),

-- (1) MISSING DATA: drop events that can't be tied to a session or user
valid_rows AS (
  SELECT *
  FROM extracted
  WHERE ga_session_id  IS NOT NULL
    AND user_pseudo_id IS NOT NULL
),

-- (2) DUPLICATE EVENTS: same user + session + event + timestamp = duplicate, keep one
deduped AS (
  SELECT * EXCEPT(row_num)
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (
        PARTITION BY user_pseudo_id, ga_session_id, event_name, event_timestamp
        ORDER BY event_timestamp
      ) AS row_num
    FROM valid_rows
  )
  WHERE row_num = 1
),

-- (3a) DUPLICATE ORDERS: one purchase per transaction_id; drop purchases with no id
purchases_clean AS (
  SELECT * EXCEPT(order_num)
  FROM (
    SELECT *,
      ROW_NUMBER() OVER (
        PARTITION BY transaction_id
        ORDER BY event_timestamp
      ) AS order_num
    FROM deduped
    WHERE event_name = 'purchase'
      AND transaction_id IS NOT NULL
  )
  WHERE order_num = 1
),

-- (3b) everything that isn't a purchase passes through untouched
non_purchases AS (
  SELECT *
  FROM deduped
  WHERE event_name != 'purchase'
)

SELECT * FROM purchases_clean
UNION ALL
SELECT * FROM non_purchases;
