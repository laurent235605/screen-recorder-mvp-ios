#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-/Users/wali_mini/.openclaw/workspace/ScreenRecorderMVP}"
STATE_DIR="${2:-/Users/wali_mini/.openclaw/workspace/.n8n/state}"
STATE_FILE="$STATE_DIR/screenrecorder_last_sha.txt"
cd "$REPO_DIR"
mkdir -p "$STATE_DIR"

START_TS=$(date +%s)

LATEST_REMOTE=$(git ls-remote origin -h refs/heads/main | awk '{print $1}')
LAST_SEEN=""
if [[ -f "$STATE_FILE" ]]; then
  LAST_SEEN=$(cat "$STATE_FILE" || true)
fi

if [[ -n "$LAST_SEEN" && "$LATEST_REMOTE" == "$LAST_SEEN" ]]; then
  jq -n \
    --arg result "nochange" \
    --arg summary "ℹ️ No new commit on main. Skipping build." \
    --arg sha "${LATEST_REMOTE:0:7}" \
    '{result:$result,summary:$summary,sha:$sha}'
  exit 0
fi

# new commit found
if git fetch origin main >/dev/null 2>&1; then
  git checkout main >/dev/null 2>&1 || true
  git pull --ff-only >/dev/null 2>&1 || true
fi
CURRENT_SHA=$(git rev-parse HEAD)

rm -rf .DerivedData
BUILD_LOG=$(mktemp)
set +e
xcodebuild \
  -project ScreenRecorderMVP.xcodeproj \
  -scheme ScreenRecorderMVP \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath ./.DerivedData \
  CODE_SIGNING_ALLOWED=NO build >"$BUILD_LOG" 2>&1
STATUS=$?
set -e

DURATION=$(( $(date +%s) - START_TS ))
WARNINGS=$(grep -c " warning: " "$BUILD_LOG" || true)
LOG_TAIL=$(tail -n 80 "$BUILD_LOG")

if [[ $STATUS -eq 0 ]]; then
  echo "$CURRENT_SHA" > "$STATE_FILE"
  jq -n \
    --arg result "success" \
    --arg summary "✅ Poll CI build passed for ${CURRENT_SHA:0:7} in ${DURATION}s (warnings: $WARNINGS)" \
    --arg sha "${CURRENT_SHA:0:7}" \
    --arg warnings "$WARNINGS" \
    '{result:$result,summary:$summary,sha:$sha,warnings:($warnings|tonumber)}'
else
  jq -n \
    --arg result "failed" \
    --arg summary "❌ Poll CI build failed for ${CURRENT_SHA:0:7} in ${DURATION}s" \
    --arg sha "${CURRENT_SHA:0:7}" \
    --arg logTail "$LOG_TAIL" \
    '{result:$result,summary:$summary,sha:$sha,logTail:$logTail}'
fi
