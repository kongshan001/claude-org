#!/usr/bin/env python3
"""org 角色发布器:把 org/agents/<slug>.md(内部规范)渲染为各 coding agent 的目标规范

用法:
  python3 publish.py <slug>                 # 发布到本机已检测到的所有目标
  python3 publish.py <slug> --target claude # 指定目标: claude|codex|cursor
  python3 publish.py <slug> --dir <path>    # 自定义目标目录(覆盖检测)

设计:
- org/agents/ 是唯一开发源;发布 = 渲染快照,目标工具直接识别
- 经验引用跨工具保持:正文强制含"开工先读经验池"指令
- 发布记录写回角色文件验证记录
"""
import argparse
import os
import re
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
AGENTS_DIR = REPO / "org" / "agents"

# 目标规范:目录解析 + frontmatter 字段
TARGETS = {
    "claude": {
        "dir": lambda home: home / ".claude" / "agents",
        "frontmatter": ["name", "description"],
    },
    "codex": {
        "dir": lambda home: home / ".codex" / "agents",
        "frontmatter": ["name", "description"],
    },
    "cursor": {
        "dir": lambda home: home / ".cursor" / "agents",
        "frontmatter": ["description"],
    },
}


def parse_role(path: Path) -> dict:
    """解析 org 角色文件:frontmatter + 职责/专长/关联话题"""
    text = path.read_text(encoding="utf-8")
    m = re.match(r"^---\n(.*?)\n---\n(.*)$", text, re.S)
    if not m:
        sys.exit(f"格式错误: {path} 缺 frontmatter")
    fm, body = m.groups()
    meta = {}
    for line in fm.splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            meta[k.strip()] = v.strip()
    info = {}
    for key in ("职责", "专长", "关联话题"):
        m2 = re.search(rf"- \*\*{key}\*\*:([^\n]*)", body)
        if m2:
            info[key] = m2.group(1).strip()
    return {"meta": meta, "info": info, "body": body}


def build_description(info: dict) -> str:
    """由职责+专长生成 Use-when 风格 description"""
    duty = info.get("职责", "")
    skills = info.get("专长", "")
    desc = f"Use this agent when a task involves {duty}"
    if skills and "|" in skills:
        parts = [p.strip() for p in skills.split("|")][:5]
        desc += f" — expertise: {' / '.join(parts)}"
    return desc


def render(slug: str, target: str, role: dict) -> str:
    meta, info = role["meta"], role["info"]
    name = meta.get("name", slug)
    desc = build_description(info)
    # 关联话题 → 经验读取指令(跨工具保持)
    topics = info.get("关联话题", "")
    exp_instruction = ""
    if topics:
        for t in re.findall(r"`([^`]+)`", topics):
            exp_instruction += (
                f"\n- 开工必读经验池: `~/.claude/org/topics/{t}/experience.md` "
                f"(持续更新,以最新为准)"
            )
    lines = ["---"]
    for field in TARGETS[target]["frontmatter"]:
        if field == "name":
            lines.append(f"name: {name}")
        elif field == "description":
            lines.append(f"description: {desc}")
    lines += ["---", "", f"你是 {name}。", f"- 职责: {info.get('职责', '')}"]
    if info.get("专长"):
        lines.append(f"- 专长: {info['专长']}")
    lines += [exp_instruction.strip(), "",
              "执行任务时遵循 org 系统的确认铁律:产出提案交回主会话,不自行落盘经验池。"]
    return "\n".join(lines)


def detect_targets(home: Path, requested: str | None) -> list[str]:
    if requested:
        if requested not in TARGETS:
            sys.exit(f"未知目标: {requested} (可选: {', '.join(TARGETS)})")
        return [requested]
    return [t for t, cfg in TARGETS.items() if cfg["dir"](home).exists()]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("slug", help="org 角色名(如 org-game-art)")
    ap.add_argument("--target", default=None, help="claude|codex|cursor(默认: 自动检测)")
    ap.add_argument("--dir", default=None, help="自定义目标目录")
    args = ap.parse_args()

    role_path = AGENTS_DIR / f"{args.slug}.md"
    if not role_path.exists():
        sys.exit(f"角色不存在: {role_path}")
    role = parse_role(role_path)

    home = Path.home()
    targets = detect_targets(home, args.target)
    if args.dir:
        targets = ["custom"]
        TARGETS["custom"] = {"dir": lambda h: Path(args.dir), "frontmatter": ["name", "description"]}

    published = []
    for t in targets:
        out_dir = TARGETS[t]["dir"](home)
        out_dir.mkdir(parents=True, exist_ok=True)
        out = out_dir / f"{args.slug}.md"
        out.write_text(render(args.slug, t, role), encoding="utf-8")
        published.append(str(out))
        print(f"✅ 已发布 [{t}]: {out}")

    # 发布记录写回角色文件验证记录
    stamp = time.strftime("%Y-%m-%d")
    rec = f"- 验证记录: "
    body = role["body"]
    if "发布记录" in body:
        new_rec = f"- **发布记录**: {', '.join(os.path.basename(p) for p in published)}({stamp})"
        body = re.sub(r"- \*\*发布记录\*\*:.*", new_rec, body)
    else:
        body = body.rstrip() + f"\n- **发布记录**: {', '.join(os.path.basename(p) for p in published)}({stamp})\n"
    role_path.write_text(
        re.sub(r"^(---\n.*?\n---\n)", lambda m: m.group(1), role_path.read_text(encoding="utf-8"))
        if False else body, encoding="utf-8") if False else None
    # 简化:直接重写 body 到原文件
    text = role_path.read_text(encoding="utf-8")
    if "发布记录" in text:
        text = re.sub(r"- \*\*发布记录\*\*:.*", f"- **发布记录**: {', '.join(os.path.basename(p) for p in published)}({stamp})", text)
    else:
        text = text.rstrip() + f"\n- **发布记录**: {', '.join(os.path.basename(p) for p in published)}({stamp})\n"
    role_path.write_text(text, encoding="utf-8")
    print(f"📝 发布记录已写回: {role_path}")


if __name__ == "__main__":
    main()
