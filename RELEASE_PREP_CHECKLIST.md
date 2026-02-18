# Release Prep Checklist (TestFlight / App Store)

Date: 2026-02-18
Project: ScreenRecorderMVP

## 1) App Store Connect setup

- [ ] Enroll paid Apple Developer Program (required for TestFlight/App Store).
- [ ] Create app record in App Store Connect.
- [ ] Confirm Bundle ID matches Xcode target (`com.example.ScreenRecorderMVP` -> production ID).
- [ ] Set SKU / app name / primary language.

## 2) StoreKit products

- [ ] Create subscriptions for:
  - [ ] Monthly (`pro.monthly` production ID)
  - [ ] Yearly (`pro.yearly` production ID)
- [ ] Add localized display name/description/pricing.
- [ ] Configure subscription group and review screenshot metadata.
- [ ] Update `AppConfig.ProductIDs` with production IDs.
- [ ] Validate sandbox purchase + restore on physical iPhone.

## 3) Signing & build

- [ ] Set Team + Signing in Xcode for app target.
- [ ] Set Team + Signing for Broadcast Upload Extension target.
- [ ] Verify extension bundle identifier naming.
- [ ] Archive in Xcode (`Any iOS Device`) without signing errors.
- [ ] Upload archive to App Store Connect.

## 4) Privacy / permissions / compliance

- [ ] Verify `NSMicrophoneUsageDescription` wording is clear and user-facing.
- [ ] Verify `NSPhotoLibraryUsageDescription` and add-only flow messaging.
- [ ] Confirm ReplayKit behavior is user-initiated only (no stealth capture).
- [ ] Add privacy policy URL in App Store Connect.
- [ ] Complete App Privacy questionnaire truthfully.

## 5) TestFlight rollout

- [ ] Internal testers added and accepted.
- [ ] Smoke test matrix completed:
  - [ ] In-app recording start/stop
  - [ ] Broadcast picker flow
  - [ ] TikTok export path
  - [ ] Paywall purchase/restore
  - [ ] Save/share post-export
- [ ] External testing notes prepared (known limitations + supported devices).

## 6) Listing assets

- [ ] App description (short + full) prepared.
- [ ] Keywords and subtitle prepared.
- [ ] Screenshots prepared for required iPhone sizes.
- [ ] Promotional text draft prepared.
- [ ] Support URL and marketing URL set.

## 7) Release gate (go/no-go)

- [ ] No P0 blockers in `APP_AUDIT_REPORT.md`.
- [ ] Build reproducibly succeeds from clean state.
- [ ] Critical funnel events visible in analytics logs:
  - [ ] `onboarding_shown`
  - [ ] `paywall_shown`
  - [ ] `purchase_tapped` / `purchase_success`
  - [ ] `export_started` / `export_success`
- [ ] Rollback plan for failed subscription rollout documented.

## Submission note template

"ScreenRecorderMVP uses ReplayKit only via explicit user action. Broadcast and recording are started from system-provided UI. No background/stealth capture is implemented."
