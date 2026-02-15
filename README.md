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

## Next (Phase 2)
- Broadcast Upload Extension for full-screen broadcast workflow.
- Clip trimming + watermark.
- Auto-upload pipeline (S3/Cloudflare R2).
- Creator templates for TikTok/Reels aspect exports.
