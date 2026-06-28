# 🛒 Ecommerce Analytics Pipeline — GA4 → BigQuery → Looker Studio
 
An end-to-end analytics project that takes raw Google Analytics 4 ecommerce event data, cleans and models it in **BigQuery** with SQL, and surfaces the insights in an interactive **Looker Studio** dashboard — complete with a business recommendation layer.
 
> **This project demonstrates the full analyst workflow:** raw event data → data engineering (cleaning, deduplication, modeling) → KPI layer → visualization → business recommendations. Not just a dashboard, but the pipeline and the reasoning behind it.
 
---
 
## 📊 Live Dashboard
 
**👉 [View the interactive Looker Studio report](https://datastudio.google.com/s/tTM0pPsyQZg)**
 
*(If the link prompts for access, the dashboard is set to "anyone with the link can view.")*
 

![Overview]<img width="1151" height="867" alt="image" src="https://github.com/user-attachments/assets/211f7480-7fc6-444c-a10c-eb49eec92a68" />
![Acquisition]<img width="1165" height="862" alt="image" src="https://github.com/user-attachments/assets/25f28976-68b8-4603-a687-2b8bce7c8417" />
![Device]<img width="1150" height="861" alt="image" src="https://github.com/user-attachments/assets/00822f1e-893b-48ad-bd2e-6421ed06edac" />
![Product]<img width="1157" height="863" alt="image" src="https://github.com/user-attachments/assets/7372f79e-4d72-4d8c-b70c-4a86ff515258" />

 
*(Add your screenshots to `docs/screenshots/` — filenames above — and they render here automatically.)*
 
---
 
## 🧰 Tech Stack
 
| Layer | Tool |
|---|---|
| Data source | Google Analytics 4 (public sample ecommerce dataset) |
| Storage & transformation | Google BigQuery (Standard SQL) |
| Visualization | Looker Studio |
| Version control / docs | GitHub |
 
---
 
## 📑 Table of Contents
 
1. [Project Overview](#-project-overview)
2. [Architecture](#-architecture)
3. [Data Source](#-data-source)
4. [Repository Structure](#-repository-structure)
5. [The Pipeline](#-the-pipeline)
6. [Key Metrics & Definitions](#-key-metrics--definitions)
7. [Business Recommendations](#-business-recommendations-summary)
8. [Data Quality & Limitations](#-data-quality--limitations)
9. [How to Reproduce](#-how-to-reproduce)
---
 
## 🎯 Project Overview
 
**Business question:** *Where is this ecommerce store winning and losing customers, and where should it focus to grow revenue?*
 
To answer it, the project breaks the customer journey down by **acquisition channel**, **device**, and **product**, and quantifies conversion, revenue, average order value, and cart abandonment at each stage of the funnel. The output is a dashboard that doesn't just report numbers — it points to specific, prioritized actions.
 
**Headline results (full date range):**
 
| Metric | Value |
|---|---|
| Total revenue | **€214,646** |
| Session conversion rate | **1.14%** |
| Pipeline stages modeled | Sessions → View Item → Add to Cart → Begin Checkout → Purchase |
 
*(A ~1–2% session conversion rate is in line with ecommerce industry norms — see [Data Quality & Limitations](#-data-quality--limitations).)*
 
---
 
## 🏗 Architecture
 
```
┌─────────────────┐     ┌──────────────────────────────┐     ┌────────────────────┐
│  Google         │     │  BigQuery                    │     │  Looker Studio     │
│  Analytics 4    │ ──► │  (data engineering layer)    │ ──► │  (presentation)    │
│                 │     │                              │     │                    │
│  Raw event      │     │  1. stg_events_clean         │     │  • Exec overview   │
│  stream         │     │     (dedupe + missing data)  │     │  • Acquisition     │
│  (one row per   │     │  2. fct_sessions             │     │  • Device          │
│   event)        │     │     (session model + channel)│     │  • Product         │
│                 │     │  3. KPI views (funnel, etc.) │     │                    │
└─────────────────┘     └──────────────────────────────┘     └────────────────────┘
 
         Data flows one direction only:  GA4 → BigQuery → Looker Studio
```
 
**The core principle:** BigQuery does all the heavy lifting (cleaning, deduplication, joining, aggregating). Looker Studio only *displays* already-clean numbers — it is never used for data cleaning. See [`docs/architecture.md`](docs/architecture.md) for the full explanation.
 
---
 
## 🗂 Data Source
 
This project uses Google's **public GA4 sample ecommerce dataset**, which is the exported event data from the Google Merchandise Store:
 
```
bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
```
 
- **Date range used:** 2020-11-01 → 2021-01-31
- **Grain:** one row per event, with nested `event_params` and `items` arrays
- **Why this dataset:** it is real GA4 export data with the identical schema to a live property, so every query here transfers directly to a production GA4 → BigQuery export by swapping a single table reference.
---
 
## 📁 Repository Structure
 
```
ecommerce-ga4-analytics/
├── README.md                        ← you are here
├── sql/
│   ├── 01_staging_clean.sql         ← cleaning: dedupe events & orders, handle missing data
│   ├── 02_fct_sessions.sql          ← session-level model + channel grouping
│   ├── 03_conversion_funnel.sql     ← funnel view (long format for charting)
│   ├── 04_conversion_by_channel.sql
│   ├── 05_conversion_by_device.sql
│   ├── 06_revenue_aov.sql           ← revenue & AOV by channel and device
│   ├── 07_device_gap.sql            ← desktop vs mobile vs tablet conversion gap
│   ├── 08_cart_abandonment.sql      ← abandonment by channel and device
│   └── 09_product_performance.sql   ← filterable product view (date/device/channel)
├── docs/
│   ├── architecture.md              ← the pipeline explained
│   ├── data_dictionary.md           ← schema fields used
│   ├── business_recommendations.md  ← full recommendations write-up
│   └── screenshots/                 ← dashboard images
└── dashboard/
    └── looker_studio_link.md        ← live report link + build notes
```
 
---
 
## 🔧 The Pipeline
 
The pipeline is three SQL stages, run in order. Each is a saved file in [`/sql`](sql/).
 
### Stage 1 — Cleaning (`01_staging_clean.sql`)
Builds `stg_events_clean` from the raw export. This stage:
- **Removes missing data** — drops events with no `ga_session_id` or `user_pseudo_id`.
- **Removes duplicate events** — same user + session + event + timestamp kept once.
- **Deduplicates orders** — one `purchase` per `transaction_id` (GA4 can fire duplicate purchase events — a real data-quality issue).
- **Handles missing revenue** — fills nulls with 0 so aggregations don't break.
### Stage 2 — Session model (`02_fct_sessions.sql`)
Builds `fct_sessions`, one clean row per session, with:
- Boolean funnel-stage flags (`reached_view_item`, `reached_add_to_cart`, …).
- A **normalized channel grouping** derived from raw `source`/`medium` (Direct, Organic Search, Paid Search, Organic Social, Email, Referral, Affiliate, Display, Other).
- Session-level revenue and transaction counts.
This is the table every dashboard query reads from — cleaning is fully separated from presentation.
 
### Stage 3 — KPI layer (`03`–`09`)
A focused query per dashboard component (funnel, conversion by channel/device, revenue & AOV, device gap, cart abandonment, product performance). The product view keeps date/device/channel dimensions so the dashboard stays fully interactive.
 
---
 
## 📐 Key Metrics & Definitions
 
| Metric | Definition |
|---|---|
| **Conversion rate** | Purchasing sessions ÷ total sessions |
| **AOV** (avg order value) | Total revenue ÷ transactions |
| **Cart abandonment rate** | (Add-to-cart sessions − purchase sessions) ÷ add-to-cart sessions |
| **View-to-purchase rate** | Product purchases ÷ product views |
| **Funnel stages** | `session_start` → `view_item` → `add_to_cart` → `begin_checkout` → `purchase` |
 
---
 
## 💡 Business Recommendations (summary)
 
The full write-up is in [`docs/business_recommendations.md`](docs/business_recommendations.md). Headlines:
 
1. **Reallocate spend toward the highest-converting channels.** Volume and conversion quality are not the same channel — the dashboard separates "lots of traffic" from "traffic that buys," revealing where extra budget would compound.
2. **Fix the mobile experience.** Mobile typically drives the most sessions but the lowest revenue-per-session and the highest cart abandonment — a checkout-friction problem, not a traffic problem.
3. **Attack the biggest funnel leak.** The steepest drop-off in the funnel is the single highest-leverage place to improve overall conversion.
4. **Merchandise smarter at the product level.** High-traffic / low-converting products signal pricing or product-page issues; low-traffic / high-converting products are promotion opportunities.
---
 
## ⚠️ Data Quality & Limitations
 
Stated openly — naming limitations is part of doing analysis honestly:
 
- **Web-only data.** The sample contains only web traffic (`platform = WEB`). A true web-vs-app comparison would require a GA4 property with an app (Firebase) data stream. Device-level analysis (mobile/desktop/tablet) is used as the platform lens instead.
- **First-touch attribution.** In this sample, `traffic_source` is user first-touch, so channel is an approximation rather than true session-scoped last-click. A production property would use `session_traffic_source_last_click`.
- **Conversion rate context.** ~1.14% is normal for ecommerce (industry norm ≈ 1–2%); the low number reflects that most sessions browse without buying, not a data error.
- **Duplicate purchases** are handled in the cleaning stage by deduplicating on `transaction_id`.
---
 
## 🔁 How to Reproduce
 
1. Open [BigQuery](https://console.cloud.google.com/bigquery) and create a project (the free sandbox tier is enough).
2. Create a dataset named `ga4_clean` — **location must be `US`** to match the public data.
3. Run the SQL files in order: `01` → `02` → then any of `03`–`09`.
   - Replace the project id `ecommerce-portfolio-451203` with your own throughout.
4. In Looker Studio, connect the BigQuery views as data sources and build the four dashboard pages (layout in [`dashboard/looker_studio_link.md`](dashboard/looker_studio_link.md)).
---
 
## 👤 About
 
Built as an ecommerce analytics portfolio project demonstrating SQL, data modeling, GA4/BigQuery, and dashboard design with a business-recommendation focus.
