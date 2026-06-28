-- ============================================================
-- 02_fct_sessions.sql
-- Stage 2: Session model
-- One clean row per session, with funnel flags, normalized
-- channel grouping, revenue and transactions.
-- Reads from the cleaned staging table. Run this SECOND.
-- ============================================================

CREATE OR REPLACE TABLE `ecommerce-portfolio-451203.ga4_clean.fct_sessions` AS

WITH sessions_raw AS (
  SELECT
    CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING))     AS session_key,
    MIN(event_date)                                                AS session_date,
    ANY_VALUE(device_category)                                     AS device_category,
    ANY_VALUE(platform)                                            AS platform,
    ANY_VALUE(source)                                              AS source,
    ANY_VALUE(medium)                                              AS medium,
    ANY_VALUE(country)                                             AS country,
    MAX(IF(event_name = 'view_item',      1, 0))                   AS reached_view_item,
    MAX(IF(event_name = 'add_to_cart',    1, 0))                   AS reached_add_to_cart,
    MAX(IF(event_name = 'begin_checkout', 1, 0))                   AS reached_begin_checkout,
    MAX(IF(event_name = 'purchase',       1, 0))                   AS reached_purchase,
    SUM(IF(event_name = 'purchase', revenue, 0))                   AS revenue,
    COUNT(DISTINCT IF(event_name = 'purchase', transaction_id, NULL)) AS transactions
  FROM `ecommerce-portfolio-451203.ga4_clean.stg_events_clean`
  GROUP BY session_key
)

SELECT
  session_key,
  session_date,
  device_category,
  platform,
  country,
  -- Normalized channel grouping (simplified GA4 default channels)
  CASE
    WHEN source = '(direct)' AND medium IN ('(none)', '(not set)')            THEN 'Direct'
    WHEN REGEXP_CONTAINS(medium, r'^(cpc|ppc|paid)')                          THEN 'Paid Search'
    WHEN medium = 'organic'                                                   THEN 'Organic Search'
    WHEN medium IN ('social','social-network','social-media','sm')
         OR REGEXP_CONTAINS(source, r'(facebook|instagram|twitter|t\.co|linkedin|youtube|pinterest|reddit)')
                                                                             THEN 'Organic Social'
    WHEN medium IN ('email','e-mail','newsletter')                           THEN 'Email'
    WHEN medium = 'referral'                                                  THEN 'Referral'
    WHEN medium = 'affiliate'                                                 THEN 'Affiliate'
    WHEN REGEXP_CONTAINS(medium, r'(display|cpm|banner)')                     THEN 'Display'
    ELSE 'Other / Unassigned'
  END                                                          AS channel,
  reached_view_item,
  reached_add_to_cart,
  reached_begin_checkout,
  reached_purchase,
  revenue,
  transactions
FROM sessions_raw;
