# n8n Automation (MVP)

## What is set up

- `workflow-a-push-build-notify.json`
  - Trigger: GitHub push event (repo: `laurent235605/screen-recorder-mvp-ios`)
  - Action: run required `xcodebuild` command via SSH node + `run_ci_build.sh`
  - Notify: Telegram success/failure message to chat `2047171592`

- `workflow-b-daily-report.json`
  - Trigger: daily at 10:00 (Asia/Shanghai)
  - Action: collect project status via SSH node + `daily_report.sh`
  - Notify: Telegram daily report

## Helper scripts

- `run_ci_build.sh` — executes required simulator build and emits JSON summary
- `daily_report.sh` — emits a compact daily status JSON

## Runtime notes

- n8n installed globally
- n8n must run under Node 24 (Node 25 is unsupported)
- Start command:

```bash
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
N8N_USER_FOLDER=/Users/wali_mini/.openclaw/workspace/.n8n \
N8N_HOST=0.0.0.0 N8N_PORT=5678 \
n8n start
```

## Credentials needed in n8n UI

1. `GitHub Laurent` (`githubApi`) — PAT with repo webhook rights.
2. `Telegram Laurent` (`telegramApi`) — bot token for notifications.
3. `Local SSH` (`sshPrivateKey`) — host `127.0.0.1`, user `wali_mini`, private key auth.

After credentials are attached, activate both workflows.
