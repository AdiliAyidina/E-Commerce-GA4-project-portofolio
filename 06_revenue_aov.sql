-- ============================================================
-- 06_revenue_aov.sql
-- Revenue, transactions and AOV by channel AND device.
-- Group by a single dimension for per-channel or per-device AOV.
-- ============================================================

CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.revenue_aov` AS
SELECT
  channel,
  device_category,
  SUM(revenue)                                   AS revenue,
  SUM(transactions)                              AS transactions,
  SAFE_DIVIDE(SUM(revenue), SUM(transactions))   AS aov
FROM `ecommerce-portfolio-451203.ga4_clean.fct_sessions`
GROUP BY channel, device_category
ORDER BY revenue DESC;
