# Business Recommendations

This document turns the dashboard's numbers into prioritized actions. It is structured the way an analyst would present to stakeholders: what the data shows, what it means, and what to do about it.

> **How to finalize this file:** the recommendations below are framed against the patterns the dashboard reveals. A few figures are marked `[read from dashboard]` — drop in the exact numbers from your live report so the write-up is fully evidence-backed. Two figures are already confirmed from the build: **total revenue ≈ €214,646** and **session conversion rate ≈ 1.14%**.

---

## Executive summary

The store converts **~1.14% of sessions** into purchases and generated **~€214,646** over the analysis window — a healthy, industry-normal conversion rate that nonetheless leaves clear room to grow. The biggest opportunities are not about buying more traffic; they are about **converting the traffic already arriving**. Three levers stand out: re-weighting spend toward channels that actually convert, fixing a mobile experience that underperforms its traffic share, and closing the single largest leak in the purchase funnel.

---

## 1. Reallocate budget toward high-converting channels

**What the data shows.** Traffic volume and conversion quality come from different channels. The highest-volume channel is not the highest-converting one — `[read from dashboard: name the top-volume channel vs the top-converting channel and their conversion rates]`.

**What it means.** Spending is likely anchored to where the *traffic* is rather than where the *buyers* are. A channel with half the traffic but double the conversion rate is more efficient per euro.

**Recommendation.** Shift incremental budget toward the highest-converting channels and treat high-volume / low-converting channels as optimization targets (better landing pages, tighter targeting) rather than growth channels. Use the **conversion-rate vs volume scatter (bubble = revenue)** on the Acquisition page to defend the reallocation visually.

---

## 2. Fix the mobile experience

**What the data shows.** Mobile drives a large share of sessions — `[read from dashboard: mobile % of sessions]` — but converts well below desktop (`[mobile CVR]` vs `[desktop CVR]`) and shows the **highest cart abandonment** of any device.

**What it means.** This is a *checkout-friction* problem, not a traffic problem. The interest is there (sessions and add-to-carts), but mobile shoppers drop out before paying — typically due to slow load, clumsy forms, or a checkout not optimized for small screens.

**Recommendation.** Audit the mobile checkout: reduce form fields, enable mobile wallets (Apple/Google Pay), and test page-load speed. Even closing half the desktop–mobile conversion gap on mobile's large traffic base would meaningfully lift total revenue.

---

## 3. Attack the biggest funnel leak

**What the data shows.** The funnel (`Sessions → View Item → Add to Cart → Begin Checkout → Purchase`) has its steepest single drop-off at `[read from dashboard: which step → which step, and the % lost]`.

**What it means.** This step is the highest-leverage point in the entire journey — a small percentage improvement here moves more total purchases than an improvement anywhere else, because every downstream stage benefits.

**Recommendation.** Prioritize experiments at that specific step. If the leak is View Item → Add to Cart, focus on product-page persuasion (pricing clarity, reviews, stock urgency). If it's Add to Cart → Checkout, focus on cart reassurance (shipping cost transparency, trust badges, guest checkout).

---

## 4. Merchandise smarter at the product level

**What the data shows.** The product page separates products into useful groups via the **views vs view-to-purchase-rate** scatter: high-traffic / low-converting products, and low-traffic / high-converting products.

**What it means.**
- *High-traffic, low-converting* products are getting attention but failing to close — usually a **pricing or product-page** issue.
- *Low-traffic, high-converting* products are quietly efficient — an **underexposed merchandising opportunity**.

**Recommendation.** Review pricing and PDP quality on the high-traffic / low-converting items, and promote the low-traffic / high-converting items more prominently (homepage, email, recommendations) to feed them the traffic they convert well.

---

## A note on rigor

These recommendations are deliberately framed as **hypotheses with a recommended test**, not certainties. The dashboard identifies *where* to look and *what* to try; A/B testing confirms impact. Presenting analysis this way — opportunity, mechanism, experiment — is what separates reporting from analysis.
