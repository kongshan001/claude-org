#!/usr/bin/env bash
# claude-org 一键安装(幂等,可重复执行)
# 依赖: bash + jq + Claude Code
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
ORG_DIR="$CLAUDE_DIR/org"
SKILL_DIR="$CLAUDE_DIR/skills/org"
SETTINGS="$CLAUDE_DIR/settings.json"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

say() { printf '\033[1;34m[claude-org]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[claude-org]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[claude-org]\033[0m %s\n' "$*" >&2; exit 1; }

command -v jq >/dev/null || die "需要 jq(Windows: winget install jq;macOS: brew install jq)"
[ -d "$CLAUDE_DIR" ] || die "未找到 ~/.claude (Claude Code 没装?)"

# ── 平台检测:Windows(Git Bash)= 复制模式;类 Unix = symlink 模式 ──
IS_WINDOWS=0
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
esac
if [ "$IS_WINDOWS" = 1 ]; then
  say "检测到 Windows(Git Bash),使用复制模式部署(仓库改动后运行 ./sync.sh 同步)"
fi

# ── 1. org/ 经验池:类 Unix 用 symlink;Windows 用复制 ──────────────
deploy_dir() { # deploy_dir <目标> <源> <名称>
  local target="$1" src="$2" name="$3"
  if [ "$IS_WINDOWS" = 1 ]; then
    if [ -d "$target" ]; then
      say "$name 已部署,跳过(改仓库后跑 ./sync.sh 更新)"
    else
      mkdir -p "$(dirname "$target")"
      cp -R "$src" "$target"
      say "已复制: $name"
    fi
    return
  fi
  if [ -L "$target" ]; then
    [ "$(readlink "$target")" = "$src" ] && say "$name 已链接,跳过" || warn "$name 指向别处,跳过"
  elif [ -e "$target" ]; then
    warn "$name 已存在真实目录,备份为 .bak-$(date +%s) 后接管"
    mv "$target" "$target.bak-$(date +%s)"
    ln -s "$src" "$target"
    say "已创建 symlink(原内容已备份)"
  else
    ln -s "$src" "$target"
    say "已创建 symlink: $target → $src"
  fi
}

deploy_dir "$ORG_DIR" "$REPO_DIR/org" "org/"

# ── 2. org skill ───────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/skills"
deploy_dir "$SKILL_DIR" "$REPO_DIR/skills/org" "skills/org"

# ── 3. hooks 脚本:复制 org-session-start.sh 到 ~/.claude/hooks/ ────
HOOKS_DIR="$CLAUDE_DIR/hooks"
mkdir -p "$HOOKS_DIR"
if [ "$REPO_DIR/hooks/org-session-start.sh" -nt "$HOOKS_DIR/org-session-start.sh" ] 2>/dev/null || [ ! -f "$HOOKS_DIR/org-session-start.sh" ]; then
  cp "$REPO_DIR/hooks/org-session-start.sh" "$HOOKS_DIR/org-session-start.sh"
  chmod +x "$HOOKS_DIR/org-session-start.sh"
  say "已安装 hooks/org-session-start.sh"
else
  say "hooks/org-session-start.sh 已是最新,跳过"
fi

# ── 4. settings.json:合并 SessionStart hook(幂等,清理旧内联版) ──
if [ ! -f "$SETTINGS" ]; then
  echo '{"hooks":{}}' > "$SETTINGS"
  say "已创建 settings.json(全新设备,空结构)"
fi
if [ "$IS_WINDOWS" = 1 ]; then
  HOOK_CMD='bash -c "~/.claude/hooks/org-session-start.sh"'
else
  HOOK_CMD="$HOME/.claude/hooks/org-session-start.sh"
fi
# 先清理历史内联命令(hook-context 字样)与已装路径版,统一为路径版
jq --arg cmd "$HOOK_CMD" '
  .hooks.SessionStart = ([.hooks.SessionStart[]? | select(any(.hooks[]?; ((.command? // "") | contains("hook-context")) or ((.command? // "") | contains("org-session-start"))) | not)]
    + [{"matcher":"startup","hooks":[{"type":"command","command":$cmd}]}])
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
say "SessionStart hook 已统一为路径版: $HOOK_CMD"

# ── 5. CLAUDE.md:追加 org 协议块(幂等) ────────────────────────────
if [ -f "$CLAUDE_MD" ]; then
  if grep -q '^# org 经验组织系统' "$CLAUDE_MD"; then
    say "CLAUDE.md 已含 org 块,跳过"
  else
    printf '\n%s\n' "---" >> "$CLAUDE_MD"
    cat "$REPO_DIR/claude-md-block.md" >> "$CLAUDE_MD"
    say "已追加 org 协议块到 CLAUDE.md"
  fi
else
  cp "$REPO_DIR/claude-md-block.md" "$CLAUDE_MD"
  say "已创建 CLAUDE.md(org 协议块)"
fi

say "完成。新开一个 Claude Code 会话即可生效(hook 不作用于当前会话)。"
say "跨设备同步:cd $REPO_DIR && git pull;沉淀经验后 git push。"
say "定时任务(日报/周报):在 Claude Code 会话环境运行 ./cron-jobs.sh 部署"
