#!/usr/bin/env bash
# org 部署健康检查:逐层诊断 5 项配置,输出 ✅/❌
set -uo pipefail

CLAUDE_DIR="$HOME/.claude"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAIL=0

check() { # check <名称> <条件命令>
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf '  \033[32m✅\033[0m %s\n' "$name"
  else
    printf '  \033[31m❌\033[0m %s\n' "$name"
    FAIL=1
  fi
}

echo "org 部署健康检查($REPO_DIR)"
echo

echo "[1] 经验池 symlink"
check "~/.claude/org → 仓库 org/" test -L "$CLAUDE_DIR/org" -a "$(readlink "$CLAUDE_DIR/org")" = "$REPO_DIR/org"

echo "[2] org skill symlink"
check "~/.claude/skills/org → 仓库 skills/org/" test -L "$CLAUDE_DIR/skills/org" -a "$(readlink "$CLAUDE_DIR/skills/org")" = "$REPO_DIR/skills/org"

echo "[3] SessionStart hook"
check "hooks 脚本已安装" test -x "$CLAUDE_DIR/hooks/org-session-start.sh"
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  check "settings.json 引用路径版 hook" bash -c "jq -e '[.hooks.SessionStart[]? | .hooks[]? | .command? // \"\" | contains(\"org-session-start\")] | any' '$CLAUDE_DIR/settings.json' >/dev/null"
else
  check "settings.json 存在" false
fi

echo "[4] CLAUDE.md org 块"
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  check "CLAUDE.md 含 org 块" grep -q '^# org 经验组织系统' "$CLAUDE_DIR/CLAUDE.md"
else
  check "CLAUDE.md 存在" false
fi

echo "[5] 定时任务(cron)"
if command -v cc-connect >/dev/null 2>&1; then
  check "日报 cron 已部署" bash -c "cc-connect cron list 2>/dev/null | grep -q 'org 每日日报'"
  check "周报 cron 已部署" bash -c "cc-connect cron list 2>/dev/null | grep -q 'org 每周周报'"
else
  check "cc-connect 可用" false
fi

echo
if [ "$FAIL" = 0 ]; then
  echo "🎉 全部就绪。新开 Claude Code 会话即可生效。"
else
  echo "⚠️ 存在缺失项,运行 ./install.sh && ./cron-jobs.sh 修复,或按 README 手动排查。"
  exit 1
fi
