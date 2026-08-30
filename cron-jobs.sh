#!/usr/bin/env bash
# org 定时任务部署(幂等,可重复执行)
# 依赖: cc-connect(Claude Code 桥)已配置;建议在 Claude Code 会话环境内执行
# 用法: ./cron-jobs.sh
set -euo pipefail

say() { printf '\033[1;34m[claude-org-cron]\033[0m %s\n' "$*"; }

command -v cc-connect >/dev/null || { echo "缺少 cc-connect" >&2; exit 1; }

DAILY_DESC="org 每日日报"
WEEKLY_DESC="org 每周周报"

DAILY_PROMPT='按 org-experience skill 的日报协议生成今日 org 系统日报:1) 读 ~/Documents/claude-org/org/INDEX.md、org/todo.md 和 ~/Documents/claude-org 仓库状态(git log、topics、agents、benchmarks、reports) 2) 按协议 spawn org-coordinator 生成日报(注入 INDEX 全文+skill 要点+git log) 3) 落盘 ~/Documents/claude-org/reports/daily/ 下,文件名用当天日期,先执行 date +%F 获取 4) 用 cc-connect send --file 发飞书 5) 仓库有变更则 git add/commit/push 同步。最后输出简短确认摘要。'

WEEKLY_PROMPT='按 org-experience skill 的周报协议生成本周 org 系统周报:1) 读 ~/Documents/claude-org/org/INDEX.md、org/todo.md 和 ~/Documents/claude-org 仓库状态(git log 本周提交、topics、agents、benchmarks、reports/weekly/TEMPLATE.md) 2) 按协议 spawn org-coordinator 生成周报(注入 INDEX 全文+skill 要点+本周 git log,遵循 TEMPLATE.md 格式) 3) 落盘 ~/Documents/claude-org/reports/weekly/ 下,文件名用当前 ISO 周号,先执行 date +%G-W%V 获取 4) 用 cc-connect send --file 发飞书 5) 仓库有变更则 git add/commit/push 同步。最后输出简短确认摘要。'

# ── 幂等清理:删除同名任务 ──────────────────────────────
cleanup() {
  local desc="$1"
  # cc-connect cron list 输出形如: ✅ 50f6b2ff  57 8 * * *  org 每日日报
  cc-connect cron list 2>/dev/null | while read -r line; do
    local id
    id=$(echo "$line" | grep -oE '^[[:space:]]*✅[[:space:]]+[0-9a-f]+' | awk '{print $2}' || true)
    if [ -n "$id" ] && echo "$line" | grep -q "$desc"; then
      cc-connect cron del "$id" >/dev/null 2>&1 && say "清理旧任务: $id ($desc)"
    fi
  done
}

cleanup "$DAILY_DESC"
cleanup "$WEEKLY_DESC"

# ── 部署 ───────────────────────────────────────────────
cc-connect cron add --cron "57 8 * * *" --prompt "$DAILY_PROMPT" --desc "$DAILY_DESC" --session-mode new-per-run
say "✅ 日报已部署(每天 08:57)"
cc-connect cron add --cron "7 9 * * 5" --prompt "$WEEKLY_PROMPT" --desc "$WEEKLY_DESC" --session-mode new-per-run
say "✅ 周报已部署(每周五 09:07)"

say "完成。查看: cc-connect cron list"
