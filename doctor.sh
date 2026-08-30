#!/usr/bin/env bash
# org 部署健康检查(最小侵入版):symlink ×2 + cron ×2
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

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    echo "[1] 经验池(复制模式)"
    check "~/.claude/org 已部署" test -d "$CLAUDE_DIR/org"
    echo "[2] org skill(复制模式)"
    check "~/.claude/skills/org 已部署" test -d "$CLAUDE_DIR/skills/org"
    ;;
  *)
    echo "[1] 经验池 symlink"
    check "~/.claude/org → 仓库 org/" test -L "$CLAUDE_DIR/org" -a "$(readlink "$CLAUDE_DIR/org")" = "$REPO_DIR/org"
    echo "[2] org skill symlink"
    check "~/.claude/skills/org → 仓库 skills/org/" test -L "$CLAUDE_DIR/skills/org" -a "$(readlink "$CLAUDE_DIR/skills/org")" = "$REPO_DIR/skills/org"
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
