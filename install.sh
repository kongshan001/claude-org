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

command -v jq >/dev/null || die "需要 jq: brew install jq"
[ -d "$CLAUDE_DIR" ] || die "未找到 ~/.claude (Claude Code 没装?)"

# ── 1. org/ 经验池:symlink 到仓库(经验随 git 跨设备同步) ──────────
if [ -L "$ORG_DIR" ]; then
  if [ "$(readlink "$ORG_DIR")" = "$REPO_DIR/org" ]; then
    say "org/ 已链接,跳过"
  else
    warn "~/.claude/org 是其他位置的 symlink,跳过(如需切换请手动处理)"
  fi
elif [ -e "$ORG_DIR" ]; then
  warn "~/.claude/org 已存在且是真实目录,备份为 org.bak-$(date +%s) 后接管"
  mv "$ORG_DIR" "$ORG_DIR.bak-$(date +%s)"
  ln -s "$REPO_DIR/org" "$ORG_DIR"
  say "已创建 symlink(原内容已备份)"
else
  ln -s "$REPO_DIR/org" "$ORG_DIR"
  say "已创建 symlink: ~/.claude/org → $REPO_DIR/org"
fi

# ── 2. org skill:symlink 到仓库 ────────────────────────────────────
mkdir -p "$CLAUDE_DIR/skills"
if [ -L "$SKILL_DIR" ]; then
  [ "$(readlink "$SKILL_DIR")" = "$REPO_DIR/skills/org" ] && say "skills/org 已链接,跳过" || warn "skills/org 指向别处,跳过"
elif [ -e "$SKILL_DIR" ]; then
  warn "skills/org 已存在真实目录,备份后接管"
  mv "$SKILL_DIR" "$SKILL_DIR.bak-$(date +%s)"
  ln -s "$REPO_DIR/skills/org" "$SKILL_DIR"
else
  ln -s "$REPO_DIR/skills/org" "$SKILL_DIR"
  say "已创建 symlink: ~/.claude/skills/org → $REPO_DIR/skills/org"
fi

# ── 3. settings.json:合并 SessionStart hook(幂等) ─────────────────
if [ -f "$SETTINGS" ]; then
  HOOK_CMD='jq -Rn --rawfile c "$HOME/.claude/org/hook-context.md" '\''{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'\'''
  if jq -e '[.hooks.SessionStart[]? | .hooks[]? | .command? // "" | contains("hook-context")] | any' "$SETTINGS" >/dev/null 2>&1; then
    say "SessionStart hook 已存在,跳过"
  else
    jq --arg cmd "$HOOK_CMD" \
      '.hooks.SessionStart += [{"matcher":"startup","hooks":[{"type":"command","command":$cmd}]}]' \
      "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    say "已合并 SessionStart hook 到 settings.json"
  fi
else
  warn "未找到 settings.json,跳过 hook(可手动按 README 添加)"
fi

# ── 4. CLAUDE.md:追加 org 协议块(幂等) ────────────────────────────
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
