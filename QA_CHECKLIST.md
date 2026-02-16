# QA Checklist (iPhone Manual Validation)

## Build & launch
- [ ] App installs and launches on physical iPhone (iOS 16+).
- [ ] No crash on first launch.
- [ ] Paywall sheet opens and closes correctly.

## Recording (in-app)
- [ ] Start recording works.
- [ ] Stop recording shows preview.
- [ ] Microphone toggle affects recorded voice track.

## Broadcast extension
- [ ] System broadcast picker appears in app.
- [ ] Broadcast extension can be selected.
- [ ] Starting/stopping broadcast does not crash app.

## TikTok export
- [ ] Non-Pro user sees paywall gate for TikTok export.
- [ ] Pro user can pick a video and export to 1080x1920.
- [ ] Export status messages progress correctly.
- [ ] Duplicate export trigger is prevented while export is in progress.

## Save / Share
- [ ] Save to Photos works when permission is granted.
- [ ] Denied photo permission shows clear guidance.
- [ ] Share sheet opens and includes expected targets.
- [ ] Missing export file path is handled gracefully.

## StoreKit
- [ ] Products load in Sandbox.
- [ ] Monthly purchase flow succeeds.
- [ ] Yearly purchase flow succeeds.
- [ ] Restore purchases updates entitlement.

## Analytics (local)
- [ ] Console prints events for paywall shown.
- [ ] purchase_tapped / purchase_success / purchase_restore emitted.
- [ ] export_started / export_success / export_failed emitted.
- [ ] save_to_photos_tapped / share_tapped emitted.
