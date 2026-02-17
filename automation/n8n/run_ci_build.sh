#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-/Users/wali_mini/.openclaw/workspace/ScreenRecorderMVP}"
cd "$REPO_DIR"

START_TS=$(date +%s)

git fetch origin >/dev/null 2>&1 || true
CURRENT_SHA=$(git rev-parse --short HEAD)
LATEST_REMOTE=$(git rev-parse --short origin/main 2>/dev/null || echo "$CURRENT_SHA")

if [[ "$CURRENT_SHA" != "$LATEST_REMOTE" ]]; then
  git pull --ff-only
  CURRENT_SHA=$(git rev-parse --short HEAD)
fi

rm -rf .DerivedData
BUILD_LOG=$(mktemp)

set +e
xcodebuild \
  -project ScreenRecorderMVP.xcodeproj \
  -scheme ScreenRecorderMVP \
  -sdk iphonesimulator \
  -derivedDataPath ./.DerivedData \
  CODE_SIGNING_ALLOWED=NO build >"$BUILD_LOG" 2>&1
STATUS=$?
set -e

DURATION=$(( $(date +%s) - START_TS ))
WARNINGS=$(grep -c " warning: " "$BUILD_LOG" || true)
ERROR_TAIL=$(tail -n 80 "$BUILD_LOG" | sed 's/"/\\"/g')

if [[ $STATUS -eq 0 ]]; then
  RESULT="success"
  SUMMARY="✅ CI build passed for $CURRENT_SHA in ${DURATION}s (warnings: $WARNINGS)"
else
  RESULT="failed"
  SUMMARY="❌ CI build failed for $CURRENT_SHA in ${DURATION}s"
fi

jq -n \
  --arg result "$RESULT" \
  --arg summary "$SUMMARY" \
  --arg sha "$CURRENT_SHA" \
  --arg duration "$DURATION" \
  --arg warnings "$WARNINGS" \
  --arg logs "$ERROR_TAIL" \
  '{result:$result,summary:$summary,sha:$sha,durationSec:($duration|tonumber),warnings:($warnings|tonumber),logTail:$logs}'
