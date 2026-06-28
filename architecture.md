# Architecture

## The mental model

This pipeline has three layers, and each does one job:

```
Google Analytics 4   →   BigQuery   →   Looker Studio
   (collection)        (engineering)    (presentation)
```

**The single most important idea:** BigQuery is *not* a second copy of the dashboard. It is the engineering layer that cleans, deduplicates, joins, and aggregates the data so that Looker Studio only ever has to *display* numbers that are already correct. Cleaning never happens in the dashboard. Data flows one direction only — it does **not** go back into Analytics.

## Why a staging + model split?

Rather than querying the raw export directly from every chart, the pipeline builds two intermediate tables:

1. **`stg_events_clean`** — the cleaning layer. Raw GA4 export is messy: duplicate events, duplicate purchase events, missing session ids, null revenue. This table fixes all of that once, so nothing downstream has to worry about it.

2. **`fct_sessions`** — the model layer. The raw export is one row per *event*; most ecommerce questions are asked per *session* ("what % of sessions converted?"). This table collapses events into one clean row per session, with funnel-stage flags and a normalized channel grouping.

Everything the dashboard reads sits on top of `fct_sessions` (or, for product detail, on `stg_events_clean`). This separation — clean once, model once, then read many times — is what keeps the KPI queries short and the dashboard fast.

## GA4 export schema notes

The GA4 → BigQuery export is **one row per event** with **nested, repeated** fields:

- `event_params` — an array of `{key, value}` pairs. The session id lives here (`ga_session_id`) and must be pulled out with `UNNEST`.
- `items` — an array of products attached to an event, unpacked with `UNNEST(items)` for product-level analysis.
- `device`, `geo`, `traffic_source`, `ecommerce` — nested records accessed with dot notation (e.g. `device.category`).

A **unique session** is the combination of `user_pseudo_id` + `ga_session_id`.

## Cost note

Queries prune by date with `_TABLE_SUFFIX BETWEEN '20201101' AND '20210131'`. BigQuery bills on data scanned, so restricting the date partition keeps every query cheap — the cleaning query scans roughly the three-month window only, not the entire dataset.
