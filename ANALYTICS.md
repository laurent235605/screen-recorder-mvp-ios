# Analytics Events

This project uses a lightweight local analytics abstraction in `Sources/AnalyticsLogger.swift`.

## Event names

- `onboarding_shown`
- `onboarding_completed`
- `paywall_shown`
- `purchase_tapped`
- `purchase_success`
- `purchase_restore`
- `export_started`
- `export_success`
- `export_failed`
- `save_to_photos_tapped`
- `share_tapped`

## Key properties in use

- `paywall_variant` (e.g. `control_a`, `value_first_b`)
- `entry_point` (e.g. `header_upgrade_cta`, `export_gate_cta`, `export_attempt_blocked`, `paywall_sheet`)
- `product_id` (StoreKit product id)
- `error` / `reason` for failure paths

## Current behavior

- Events are logged locally via `LocalAnalyticsLogger` using `print` with ISO-8601 timestamps.
- Optional event properties can be attached (for example, `product_id` or export error details).

## Future provider integration points

- Replace `Analytics.logger` at app startup with a concrete provider-backed implementation.
- Keep the event names stable and provider-agnostic by continuing to call `Analytics.log(...)` from feature code.
- Provider-specific mapping, batching, and user/session context should live inside the analytics logger implementation, not UI/business logic.
