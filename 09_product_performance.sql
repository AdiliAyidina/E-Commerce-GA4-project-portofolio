-- ============================================================
-- 09_product_performance.sql
-- Product-level performance, KEEPING date/device/channel so the
-- dashboard stays interactive. The chart applies "top 10 by
-- revenue" AFTER filters, so the top 10 recomputes per slice.
-- ============================================================

CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.product_performance` AS
SELECT
  e.event_date                                   AS session_date,
  e.device_category,
  s.channel,
  item.item_name                                 AS item_name,
  COUNTIF(e.event_name = 'view_item')            AS views,
  COUNTIF(e.event_name = 'add_to_cart')          AS add_to_carts,
  COUNTIF(e.event_name = 'purchase')             AS purchases,
  SUM(IF(e.event_name = 'purchase', item.item_revenue_in_usd, 0)) AS revenue,
  SUM(IF(e.event_name = 'purchase', item.quantity, 0))            AS units_sold
FROM `ecommerce-portfolio-451203.ga4_clean.stg_events_clean` AS e,
     UNNEST(e.items) AS item
LEFT JOIN `ecommerce-portfolio-451203.ga4_clean.fct_sessions` AS s
  ON CONCAT(e.user_pseudo_id, '-', CAST(e.ga_session_id AS STRING)) = s.session_key
WHERE e.event_name IN ('view_item', 'add_to_cart', 'purchase')
GROUP BY session_date, device_category, channel, item_name;
