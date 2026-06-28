-- ============================================================
-- 04_conversion_by_channel.sql
-- Sessions, purchases and conversion rate by acquisition channel.
-- ============================================================

CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.conversion_by_channel` AS
SELECT
  channel,
  COUNT(*)                                       AS sessions,
  SUM(reached_purchase)                          AS purchases,
  SAFE_DIVIDE(SUM(reached_purchase), COUNT(*))   AS conversion_rate,
  SUM(revenue)                                   AS revenue
FROM `ecommerce-portfolio-451203.ga4_clean.fct_sessions`
GROUP BY channel
ORDER BY sessions DESC;
