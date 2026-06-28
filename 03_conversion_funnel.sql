-- ============================================================
-- 03_conversion_funnel.sql
-- Conversion funnel in long format (one row per stage) so it
-- can be charted as a sorted horizontal bar in Looker Studio.
-- Includes drop-off % from the previous stage.
-- ============================================================

CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.funnel` AS
WITH totals AS (
  SELECT
    COUNT(*)                     AS s_sessions,
    SUM(reached_view_item)       AS s_view,
    SUM(reached_add_to_cart)     AS s_cart,
    SUM(reached_begin_checkout)  AS s_checkout,
    SUM(reached_purchase)        AS s_purchase
  FROM `ecommerce-portfolio-451203.ga4_clean.fct_sessions`
),
stages AS (
  SELECT 1 AS step_order, 'Sessions'       AS stage, s_sessions AS sessions FROM totals
  UNION ALL SELECT 2, 'View Item',      s_view     FROM totals
  UNION ALL SELECT 3, 'Add to Cart',    s_cart     FROM totals
  UNION ALL SELECT 4, 'Begin Checkout', s_checkout FROM totals
  UNION ALL SELECT 5, 'Purchase',       s_purchase FROM totals
)
SELECT
  step_order,
  stage,
  sessions,
  SAFE_DIVIDE(sessions, MAX(sessions) OVER ())                                  AS pct_of_sessions,
  SAFE_DIVIDE(sessions, LAG(sessions) OVER (ORDER BY step_order))               AS step_conversion,
  1 - SAFE_DIVIDE(sessions, LAG(sessions) OVER (ORDER BY step_order))           AS step_dropoff
FROM stages
ORDER BY step_order;
