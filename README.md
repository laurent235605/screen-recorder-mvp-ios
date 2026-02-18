# iOS Screen Recorder MVP (ReplayKit, App Store compliant)

## Goal
Build an iOS app that can record screen + microphone audio in an Apple-compliant way.

## Platform constraints (important)
- iOS does **not** allow silent/background global recording by apps.
- In-app recording: use `RPScreenRecorder.startRecording`.
- Global broadcast recording: use ReplayKit Broadcast Upload Extension (user must start from system UI).

## MVP scope (Phase 1)
1. Start/stop recording in-app screen.
2. Optional microphone audio (`isMicrophoneEnabled`).
3. Preview recorded video.
4. Save to Photos.
5. Basic error handling + permission guidance.

## Files
- `Sources/ScreenRecorderService.swift`
- `Sources/ContentView.swift`
- `Sources/InfoPlistKeys.md`

## How to use
1. Create an iOS SwiftUI App project in Xcode (`iOS 16+`).
2. Add these source files into project.
3. Add `NSMicrophoneUsageDescription` in Info.plist.
4. Run on physical device for real testing.

## Current capabilities
- In-app ReplayKit recording (screen + optional microphone).
- Broadcast Upload Extension scaffold for system broadcast flow.
- TikTok 9:16 export (1080x1920) with center-crop scaling.
- Export post-actions: Save to Photos + Share sheet.
- StoreKit 2 commercialization scaffold (paywall, purchase, restore, entitlement gate).
- Local analytics event logging abstraction.

## Known limitations
- Broadcast behavior must be validated on physical device (simulator limitations).
- Product IDs are placeholders until App Store Connect products are configured.
- Analytics currently logs locally; remote provider integration is pending.
- No server-side receipt validation yet.

## Next (Phase 3)
- Onboarding and first-export funnel tuning.
- Crash/telemetry integration.
- Optional cloud upload pipeline and creator presets.

## Release docs
- `RELEASE_PREP_CHECKLIST.md` — end-to-end release readiness checklist.
- `TESTFLIGHT_PLAYBOOK.md` — practical rollout flow from archive to external testers.

## Growth docs
- `GROWTH_METRICS_DASHBOARD.md` — KPI and experiment metric definitions for paywall/onboarding/export funnel.
