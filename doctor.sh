#!/usr/bin/env bash
# org 部署健康检查:数据层 + skill symlink + cron
# 不再检查 settings.json / CLAUDE.md(部署零侵入)
set -uo pipefail

CLAUDE_DIR="$HOME/.claude"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAIL=0

check() {
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then printf '  \033[32m✅\033[0m %s\n' "$name"
  else printf '  \033[31m❌\033[0m %s\n' "$name"; FAIL=1; fi
}

echo "org 部署健康检查(最小侵入版, $REPO_DIR)"
echo

echo "[1] 数据层(独立目录,零 .claude 依赖)"
check "经验池 $REPO_DIR/org/ 存在" test -d "$REPO_DIR/org"
echo "[2] org-agent skill"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    check "~/.claude/skills/org-agent 已部署(复制)" test -d "$CLAUDE_DIR/skills/org-agent"
    ;;
  *)
    check "~/.claude/skills/org-agent → 仓库" test -L "$CLAUDE_DIR/skills/org-agent" -a "$(readlink "$CLAUDE_DIR/skills/org-agent")" = "$REPO_DIR/skills/org-agent"
    ;;
esac

echo "[3] 定时任务(cron)"
if command -v cc-connect >/dev/null 2>&1; then
  check "日报 cron 已部署" bash -c "cc-connect cron list 2>/dev/null | grep -q 'org 每日日报'"
  check "周报 cron 已部署" bash -c "cc-connect cron list 2>/dev/null | grep -q 'org 每周周报'"
else
  check "cc-connect 可用" false
fi

echo
if [ "$FAIL" = 0 ]; then
  echo "🎉 全部就绪。新开 Claude Code 会话,说\"部署 org\"或任意触发词即可激活。"
else
  echo "⚠️ 存在缺失项:运行 ./install.sh(必要时 ./cron-jobs.sh)修复。"
  exit 1
fi
