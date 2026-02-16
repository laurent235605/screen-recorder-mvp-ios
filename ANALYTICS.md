# Analytics Events

This project uses a lightweight local analytics abstraction in `Sources/AnalyticsLogger.swift`.

## Event names

- `paywall_shown`
- `purchase_tapped`
- `purchase_success`
- `purchase_restore`
- `export_started`
- `export_success`
- `export_failed`
- `save_to_photos_tapped`
- `share_tapped`

## Current behavior

- Events are logged locally via `LocalAnalyticsLogger` using `print` with ISO-8601 timestamps.
- Optional event properties can be attached (for example, `product_id` or export error details).

## Future provider integration points

- Replace `Analytics.logger` at app startup with a concrete provider-backed implementation.
- Keep the event names stable and provider-agnostic by continuing to call `Analytics.log(...)` from feature code.
- Provider-specific mapping, batching, and user/session context should live inside the analytics logger implementation, not UI/business logic.
