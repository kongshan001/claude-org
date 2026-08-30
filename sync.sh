#!/usr/bin/env bash
# 复制模式(Windows/Git Bash)下手动同步:仓库 → ~/.claude
# 类 Unix(symlink 模式)无需本脚本;仓库改动后 Windows 上跑一次即可
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

say() { printf '\033[1;34m[claude-org-sync]\033[0m %s\n' "$*"; }

[ -d "$CLAUDE_DIR" ] || { echo "未找到 ~/.claude" >&2; exit 1; }

# 数据层(经验池/角色/用例)直接使用仓库目录,零 .claude 依赖 —— 无需同步
mkdir -p "$CLAUDE_DIR/skills"
rm -rf "$CLAUDE_DIR/skills/org-agent"
cp -R "$REPO_DIR/skills/org-agent" "$CLAUDE_DIR/skills/org-agent"
say "已同步 skills/org-agent"

mkdir -p "$CLAUDE_DIR/hooks"
cp "$REPO_DIR/hooks/org-session-start.sh" "$CLAUDE_DIR/hooks/org-session-start.sh"
chmod +x "$CLAUDE_DIR/hooks/org-session-start.sh" 2>/dev/null || true
say "已同步 hooks/org-session-start.sh"

say "完成。新开 Claude Code 会话生效。"
