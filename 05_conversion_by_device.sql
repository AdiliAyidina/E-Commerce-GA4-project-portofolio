-- ============================================================
-- 05_conversion_by_device.sql
-- Sessions, purchases and conversion rate by device category.
-- ============================================================

CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.conversion_by_device` AS
SELECT
  device_category,
  COUNT(*)                                       AS sessions,
  SUM(reached_purchase)                          AS purchases,
  SAFE_DIVIDE(SUM(reached_purchase), COUNT(*))   AS conversion_rate,
  SUM(revenue)                                   AS revenue
FROM `ecommerce-portfolio-451203.ga4_clean.fct_sessions`
GROUP BY device_category
ORDER BY sessions DESC;
