# Data Dictionary

## Source: `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

Key raw fields used in this project:

| Field | Type | Description |
|---|---|---|
| `event_date` | STRING | Event date, `YYYYMMDD` |
| `event_timestamp` | INT64 | Microseconds since epoch |
| `event_name` | STRING | e.g. `session_start`, `view_item`, `add_to_cart`, `begin_checkout`, `purchase` |
| `event_params` | ARRAY<STRUCT> | Key/value pairs; holds `ga_session_id` |
| `user_pseudo_id` | STRING | Anonymous user/device id |
| `device.category` | STRING | `desktop` / `mobile` / `tablet` |
| `platform` | STRING | `WEB` / `ANDROID` / `IOS` (web-only in this sample) |
| `traffic_source.source` | STRING | Acquisition source |
| `traffic_source.medium` | STRING | Acquisition medium |
| `geo.country` | STRING | Country |
| `ecommerce.purchase_revenue_in_usd` | FLOAT64 | Revenue on a purchase event |
| `ecommerce.transaction_id` | STRING | Order id (used to deduplicate purchases) |
| `items` | ARRAY<STRUCT> | Products in the event (name, price, quantity, revenue) |

---

## Model: `ga4_clean.stg_events_clean`

Cleaned, flattened event table (one row per event, deduplicated).

| Column | Description |
|---|---|
| `user_pseudo_id` | Anonymous user id (not null) |
| `ga_session_id` | Session id, extracted from `event_params` (not null) |
| `event_name` | Event type |
| `event_timestamp` | Event time (micros) |
| `event_date` | Parsed DATE |
| `device_category` | Device |
| `platform` | Platform |
| `source`, `medium` | Raw acquisition source/medium |
| `country` | Country |
| `revenue` | Purchase revenue, nulls filled with 0 |
| `transaction_id` | Order id (deduplicated) |
| `items` | Product array (carried through for product analysis) |

---

## Model: `ga4_clean.fct_sessions`

One row per session. The table all KPI queries read from.

| Column | Description |
|---|---|
| `session_key` | `user_pseudo_id` + `-` + `ga_session_id` (unique per session) |
| `session_date` | Session date |
| `device_category` | Device |
| `platform` | Platform |
| `country` | Country |
| `channel` | Normalized channel grouping (Direct, Organic Search, Paid Search, Organic Social, Email, Referral, Affiliate, Display, Other) |
| `reached_view_item` | 1 if session viewed a product |
| `reached_add_to_cart` | 1 if session added to cart |
| `reached_begin_checkout` | 1 if session began checkout |
| `reached_purchase` | 1 if session purchased |
| `revenue` | Session purchase revenue |
| `transactions` | Distinct transactions in the session |

---

## Channel grouping logic

Derived from raw `source` / `medium`:

| Channel | Rule |
|---|---|
| Direct | source `(direct)` and medium `(none)`/`(not set)` |
| Paid Search | medium starts with `cpc`/`ppc`/`paid` |
| Organic Search | medium = `organic` |
| Organic Social | social mediums, or known social sources |
| Email | medium `email`/`newsletter` |
| Referral | medium = `referral` |
| Affiliate | medium = `affiliate` |
| Display | medium contains `display`/`cpm`/`banner` |
| Other / Unassigned | everything else |
