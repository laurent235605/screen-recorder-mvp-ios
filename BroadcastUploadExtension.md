# ReplayKit Broadcast Upload Extension Flow

This project now includes a `BroadcastUploadExtension` target with `SampleHandler.swift` scaffolded for ReplayKit broadcast upload.

## How users start global recording (App Store-compliant)
1. User opens iOS Control Center.
2. User long-presses the Screen Recording control.
3. User selects `ScreenRecorderMVP` broadcast extension from the list.
4. User taps **Start Broadcast**.
5. iOS starts ReplayKit broadcast and delivers video/audio sample buffers to `SampleHandler`.

Alternative: the app can present `RPSystemBroadcastPickerView` to launch the same system-managed flow.

## Important limitations
- Silent/background global recording without explicit system UI and user consent is not allowed on iOS.
- Broadcast upload extensions receive sample buffers only after user starts from system UI (or system picker).
- Real end-to-end validation should be done on a physical iOS device.

## Current environment build note
Build attempts in this environment are partially constrained:
- `xcodebuild -list -project ScreenRecorderMVP.xcodeproj` succeeds and shows both targets/schemes.
- A default simulator build that writes to `~/Library/Developer/Xcode/DerivedData` fails in this sandbox due permissions.
- A simulator SDK build succeeds when `-derivedDataPath` is pointed to a writable local folder (for example: `./.DerivedData`), and it compiles both app + extension and embeds the `.appex`.

Runtime testing is still best done in a normal local Xcode session on simulator/device, especially physical device for broadcast behavior.
