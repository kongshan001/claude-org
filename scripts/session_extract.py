#!/usr/bin/env python3
"""Claude Code 会话 transcript 提取器:jsonl → 可分析的纯文本

用法:
  python3 session_extract.py <session.jsonl> <output.txt> [max_lines]

说明:
- 只提取 user/assistant 的文本内容,跳过系统消息/工具结果
- 工具调用折叠为 [TOOL:name] 占位,控制噪声
- 输出格式:每行 "[user] ..." 或 "[assistant] ..."
"""
import json
import sys


def extract(path, out, max_lines=4000):
    texts = []
    with open(path, encoding="utf-8") as f:
        for i, line in enumerate(f):
            if i >= max_lines:
                break
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            t = obj.get("type")
            if t not in ("user", "assistant"):
                continue
            msg = obj.get("message", {})
            content = msg.get("content")
            if isinstance(content, str):
                texts.append((t, content))
            elif isinstance(content, list):
                parts = []
                for c in content:
                    if isinstance(c, dict):
                        if c.get("type") == "text":
                            parts.append(c.get("text", ""))
                        elif c.get("type") == "tool_use":
                            parts.append(f"[TOOL:{c.get('name')}]")
                if parts:
                    texts.append((t, " ".join(parts)))
    with open(out, "w", encoding="utf-8") as f:
        for t, txt in texts:
            f.write(f"[{t}] {txt}\n")
    chars = sum(len(t) for _, t in texts)
    print(f"{out}: {len(texts)} 条消息, {chars} 字符, 约 {chars // 3} tokens")
    return chars


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    max_lines = int(sys.argv[3]) if len(sys.argv) > 3 else 4000
    extract(sys.argv[1], sys.argv[2], max_lines)
