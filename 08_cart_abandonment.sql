-- ============================================================
-- 08_cart_abandonment.sql
-- Cart abandonment rate by channel and by device.
-- Abandonment = (carts - purchases) / carts, among sessions
-- that added to cart.
-- ============================================================

-- By channel
CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.cart_abandonment_channel` AS
SELECT
  channel,
  SUM(reached_add_to_cart)                       AS carts,
  SUM(reached_purchase)                          AS purchases,
  SAFE_DIVIDE(SUM(reached_add_to_cart) - SUM(reached_purchase),
              SUM(reached_add_to_cart))          AS cart_abandonment_rate
FROM `ecommerce-portfolio-451203.ga4_clean.fct_sessions`
WHERE reached_add_to_cart = 1
GROUP BY channel
ORDER BY carts DESC;

-- By device
CREATE OR REPLACE VIEW `ecommerce-portfolio-451203.ga4_clean.cart_abandonment_device` AS
SELECT
  device_category,
  SUM(reached_add_to_cart)                       AS carts,
  SUM(reached_purchase)                          AS purchases,
  SAFE_DIVIDE(SUM(reached_add_to_cart) - SUM(reached_purchase),
              SUM(reached_add_to_cart))          AS cart_abandonment_rate
FROM `ecommerce-portfolio-451203.ga4_clean.fct_sessions`
WHERE reached_add_to_cart = 1
GROUP BY device_category
ORDER BY carts DESC;
