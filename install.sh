#!/usr/bin/env bash
# org 部署(最小侵入版):只做 symlink,不碰 settings.json / CLAUDE.md
# 能力全部走 skills 命名空间:模型读 org skill 即获得全部协议
# 幂等,可重复执行;Windows(Git Bash)= 复制模式 + ./sync.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
ORG_DIR="$CLAUDE_DIR/org"
SKILL_DIR="$CLAUDE_DIR/skills/org"

say() { printf '\033[1;34m[claude-org]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[claude-org]\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m[claude-org]\033[0m %s\n' "$*" >&2; exit 1; }

[ -d "$CLAUDE_DIR" ] || die "未找到 ~/.claude (Claude Code 没装?)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1; say "Windows(Git Bash):复制模式,仓库改动后跑 ./sync.sh" ;;
  *) IS_WINDOWS=0 ;;
esac

deploy_dir() { # deploy_dir <目标> <源> <名称>
  local target="$1" src="$2" name="$3"
  if [ "$IS_WINDOWS" = 1 ]; then
    if [ -d "$target" ]; then say "$name 已部署,跳过(改仓库后跑 ./sync.sh)"; else
      mkdir -p "$(dirname "$target")"; cp -R "$src" "$target"; say "已复制: $name"; fi
    return
  fi
  if [ -L "$target" ]; then
    [ "$(readlink "$target")" = "$src" ] && say "$name 已链接,跳过" || warn "$name 指向别处,跳过"
  elif [ -e "$target" ]; then
    warn "$name 已存在真实目录,备份为 .bak-$(date +%s) 后接管"
    mv "$target" "$target.bak-$(date +%s)"; ln -s "$src" "$target"; say "已创建 symlink(原内容已备份)"
  else
    ln -s "$src" "$target"; say "已创建 symlink: $target → $src"
  fi
}

deploy_dir "$ORG_DIR" "$REPO_DIR/org" "org/"
mkdir -p "$CLAUDE_DIR/skills"
deploy_dir "$SKILL_DIR" "$REPO_DIR/skills/org" "skills/org"

say "完成。未改动 settings.json / CLAUDE.md(最小侵入)。"
say "新开会话后:模型已可通过 org skill 感知系统(触发词:沉淀/分工/派agent/压测/日报/部署)。"
say "定时任务(日报/周报,可选):在 Claude Code 会话环境运行 ./cron-jobs.sh"
