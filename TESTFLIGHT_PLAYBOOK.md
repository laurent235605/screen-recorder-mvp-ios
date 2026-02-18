# TestFlight Playbook

## Goal
Ship a stable beta quickly once paid developer enrollment is active.

## Step-by-step

1. **Freeze candidate branch**
   - Tag candidate commit.
   - Run simulator build verification.
   - Run physical device QA checklist.

2. **Archive + upload**
   - Xcode -> Product -> Archive.
   - Distribute App -> App Store Connect -> Upload.
   - Wait for processing.

3. **Internal test phase (24-48h)**
   - Invite internal testers first.
   - Validate recording, broadcast, export, paywall, restore.
   - Capture crashes and funnel anomalies.

4. **External test phase**
   - Provide a short tester guide:
     - how to start recording
     - what Pro unlocks
     - known limitations
   - Monitor event counts and error reports daily.

5. **Promotion readiness checks**
   - Ensure paywall variant analytics shows distribution.
   - Verify purchase conversion path end-to-end.
   - Ensure support channel SLA for beta issues.

## Exit criteria to App Store submission

- No critical crash in top user paths.
- Purchase and restore success in sandbox and TestFlight accounts.
- Export flow success rate acceptable (target >95% in tested devices).
- ReplayKit flows validated on at least 2 iPhone models.
