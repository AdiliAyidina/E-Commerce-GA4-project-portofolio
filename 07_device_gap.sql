-- ============================================================
-- 07_device_gap.sql
-- Conversion rate pivoted by device, per channel, to expose the
-- desktop vs mobile vs tablet performance gap.
-- ============================================================

CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.device_gap` AS
SELECT
  channel,
  SAFE_DIVIDE(SUM(IF(device_category='desktop', reached_purchase,0)),
              SUM(IF(device_category='desktop', 1, 0)))  AS cvr_desktop,
  SAFE_DIVIDE(SUM(IF(device_category='mobile',  reached_purchase,0)),
              SUM(IF(device_category='mobile',  1, 0)))  AS cvr_mobile,
  SAFE_DIVIDE(SUM(IF(device_category='tablet',  reached_purchase,0)),
              SUM(IF(device_category='tablet',  1, 0)))  AS cvr_tablet
FROM `ecommerce-portfolio-451203.ga4_clean.fct_sessions`
GROUP BY channel
ORDER BY channel;
