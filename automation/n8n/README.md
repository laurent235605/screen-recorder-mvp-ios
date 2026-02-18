# n8n Automation (MVP)

## Active setup (recommended)

- `workflow-c-poll-build-notify-v3.json`
  - Trigger: every 5 minutes
  - Action: checks `origin/main` for new commit; if changed, runs required iOS simulator build
  - Notify: Telegram success/failure only (no spam when unchanged)
  - Why: avoids GitHub webhook/public URL requirements while remote

## Legacy workflows (kept for reference)

- `workflow-a-push-build-notify.json` (webhook-based; requires publicly reachable WEBHOOK_URL)
- `workflow-b-daily-report.json` (daily status report)

## Helper scripts

- `run_ci_build.sh` — one-shot build + JSON output
- `run_poll_build.sh` — poll `origin/main`, build on new SHA, JSON output
- `daily_report.sh` — compact daily report JSON

## Runtime notes

- n8n runs under Node 24
- Start script: `/Users/wali_mini/.openclaw/workspace/.n8n/start_n8n.sh`

## Credentials needed in n8n

1. GitHub API credential (only needed by webhook workflow)
2. Telegram API credential
3. SSH Private Key credential (`127.0.0.1:22`, user `wali_mini`)
