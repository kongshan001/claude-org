#!/usr/bin/env bash
# org SessionStart hook —— 会话启动时注入 org 协议 + 角色池
# 由 ~/.claude/settings.json 的 SessionStart hook 调用(install.sh 负责安装)
# 可单独测试: echo '{}' | ./org-session-start.sh
set -euo pipefail

ORG_DIR="${HOME}/.claude/org"

if [ ! -f "$ORG_DIR/hook-context.md" ]; then
  # 未部署完成:静默退出(hook 失败不应阻断会话)
  exit 0
fi

{
  cat "$ORG_DIR/hook-context.md"
  if [ -f "$ORG_DIR/INDEX.md" ]; then
    printf '\n## 当前 Agent 角色池(INDEX.md)\n'
    cat "$ORG_DIR/INDEX.md"
  fi
} | jq -Rs '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:.}}'
