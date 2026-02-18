# Growth Metrics Dashboard Spec (Phase 4)

Date: 2026-02-18

This file defines a stable KPI layer so A/B and funnel work can be evaluated consistently.

## 1) Core funnel definitions

### F1. Onboarding completion rate
- Numerator: unique users with `onboarding_completed`
- Denominator: unique users with `onboarding_shown`
- Formula: `onboarding_completed / onboarding_shown`

### F2. Paywall click-through rate (CTR)
- Numerator: unique users with `purchase_tapped`
- Denominator: unique users with `paywall_shown`
- Formula: `purchase_tapped / paywall_shown`

### F3. Paywall conversion rate (CVR)
- Numerator: unique users with `purchase_success`
- Denominator: unique users with `paywall_shown`
- Formula: `purchase_success / paywall_shown`

### F4. Export success rate
- Numerator: count(`export_success`)
- Denominator: count(`export_started`)
- Formula: `export_success / export_started`

### F5. Save intent rate (post-export)
- Numerator: count(`save_to_photos_tapped`)
- Denominator: count(`export_success`)
- Formula: `save_to_photos_tapped / export_success`

## 2) A/B experiment breakdowns

All KPIs above should be segmented by:
- `paywall_variant` (`control_a`, `value_first_b`)
- `entry_point` (`header_upgrade_cta`, `export_gate_cta`, `export_attempt_blocked`, `paywall_sheet`)

## 3) Minimum dashboard panels

1. Variant split health
   - `paywall_shown` counts by `paywall_variant`
2. Variant CTR
   - `purchase_tapped / paywall_shown` by variant
3. Variant CVR
   - `purchase_success / paywall_shown` by variant
4. Entry-point quality
   - `purchase_success / paywall_shown` by entry_point
5. Export reliability
   - `export_success / export_started`

## 4) Decision thresholds (initial)

- Keep winner only when both are true:
  - Relative lift >= +10%
  - Minimum 100 paywall_shown per variant
- If sample size is smaller, continue experiment and avoid hard conclusions.

## 5) Provider mapping checklist (Firebase/Amplitude/PostHog)

- Keep event names unchanged.
- Preserve `paywall_variant`, `entry_point`, `product_id`, `error` properties.
- Add stable user_id/session_id at logger layer only.
- Centralize property normalization in analytics adapter.
