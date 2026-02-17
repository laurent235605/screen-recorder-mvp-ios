#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${1:-/Users/wali_mini/.openclaw/workspace/ScreenRecorderMVP}"
cd "$REPO_DIR"

git fetch origin >/dev/null 2>&1 || true
LAST3=$(git log --pretty=format:'- %h %s (%cr)' -n 3)
CHANGED=$(git status --porcelain | wc -l | tr -d ' ')

HEALTH="✅ healthy"
if [[ "$CHANGED" != "0" ]]; then
  HEALTH="⚠️ uncommitted changes: $CHANGED"
fi

jq -n \
  --arg health "$HEALTH" \
  --arg last3 "$LAST3" \
  '{health:$health,lastCommits:$last3,nextActions:["A/B paywall variant instrumentation","Onboarding funnel polish","Release/TestFlight checklist prep"]}'
