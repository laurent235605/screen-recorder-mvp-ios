# PRODUCT_STRATEGY.md

Date: 2026-02-18
Scope: ScreenRecorderMVP product direction (iOS 16+)

## 1) Product thesis
Users pay for speed-to-publish. The product should minimize time from source clip to platform-ready 9:16 output.

## 2) Core jobs-to-be-done
- Record screen or import clip
- Convert to publish-ready 9:16 quickly
- Save/share with minimal friction

## 3) Strategy pillars
1. Reliability first (export must consistently succeed)
2. Frictionless conversion path (clear paywall + restore + state clarity)
3. Measurable iteration (event-driven decisions)

## 4) Priority roadmap

### P0 (now)
- Stabilize export, save, share states
- Maintain ReplayKit compliance
- Keep paywall + purchase + restore robust

### P1 (next)
- Improve onboarding to first successful export
- Optimize paywall variant performance
- Better entitlement messaging in all key screens

### P2 (later)
- Creator presets / template bundles
- Batch export or advanced pro features
- Optional cloud sync/upload workflows

## 5) Monetization strategy in-product
- Free:
  - Recording + basic flow exposure
- Pro:
  - TikTok 9:16 export and future speed features
- Rule: monetize value acceleration, not basic trust-building actions

## 6) UX principles
- One-tap obvious primary action
- Error states must be actionable
- Avoid ambiguous status; show entitlement clearly

## 7) Release strategy
- Continue simulator CI checks
- Physical-device QA for ReplayKit/broadcast paths
- TestFlight-first rollout when account is ready

## 8) Success metrics
- Activation: first successful export within first session
- Conversion: `purchase_success / paywall_shown`
- Retention proxy: repeat export starts per user/week
- Reliability: `export_success / export_started`

## 9) Decision rules
- No feature addition that reduces export reliability
- If conversion drops >10% after change, rollback and review funnel events
- Promote only changes with measurable KPI uplift
