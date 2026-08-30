#!/usr/bin/env python3
"""会话 transcript 提取器(Claude Code .jsonl + DSH .jsonl.zstd)→ 可分析的纯文本

用法:
  python3 session_extract.py <session.jsonl[.zstd]> <output.txt> [max_lines]

说明:
- 自动检测格式:Claude Code(type/message)或 DSH 事件流(type/seq/time/data)
- 输入 .zstd 自动解压(优先 python zstandard 库,fallback zstd CLI)
- 只提取 user/assistant 文本,跳过系统/推理(reasoning)/工具结果
- 工具调用折叠为 [TOOL:name] 占位
- 输出格式:每行 "[user] ..." 或 "[assistant] ..."
"""
import json
import shutil
import subprocess
import sys
import tempfile


def open_maybe_zstd(path):
    """返回可迭代行:.zstd 先解压(zstandard 库优先,fallback zstd CLI)"""
    if not (path.endswith(".zstd") or path.endswith(".zst")):
        return open(path, encoding="utf-8")
    tmp = tempfile.NamedTemporaryFile("w+", encoding="utf-8", delete=False, suffix=".jsonl")
    try:
        import zstandard  # 优先 python 库
        with open(path, "rb") as f:
            dctx = zstandard.ZstdDecompressor()
            with dctx.stream_reader(f) as reader:
                tmp.write(reader.read().decode("utf-8", errors="replace"))
    except ImportError:
        zstd = shutil.which("zstd")
        if not zstd:
            sys.exit("需要 zstd: brew install zstd 或 pip install zstandard")
        subprocess.run([zstd, "-d", "-c", path], stdout=tmp, check=True)
    tmp.seek(0)
    return tmp


def extract_cc(texts, obj, max_lines):
    """Claude Code 格式:type=user/assistant, message.content"""
    t = obj.get("type")
    if t not in ("user", "assistant"):
        return
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


def extract_dsh(texts, obj):
    """DSH 事件流:user/message + assistant/message, tool/call 折叠"""
    t = obj.get("type")
    data = obj.get("data", {})
    if t == "user/message":
        parts = []
        for c in data.get("content", []) or []:
            if isinstance(c, dict) and c.get("type") == "text":
                parts.append(c.get("text", ""))
        if parts:
            texts.append(("user", " ".join(parts)))
    elif t == "assistant/message":
        msg = data.get("message", {})
        parts = []
        for c in (msg.get("content", []) or []) if isinstance(msg, dict) else []:
            if isinstance(c, dict) and c.get("type") == "text":
                parts.append(c.get("text", ""))
        if parts:
            texts.append(("assistant", " ".join(parts)))
    elif t == "tool/call":
        name = ""
        if isinstance(data, dict):
            name = data.get("name") or data.get("tool") or ""
        texts.append(("assistant", f"[TOOL:{name}]"))


def extract(path, out, max_lines=4000):
    texts = []
    f = open_maybe_zstd(path)
    try:
        for i, line in enumerate(f):
            if i >= max_lines:
                break
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            t = obj.get("type")
            if t in ("user", "assistant"):
                extract_cc(texts, obj, max_lines)
            elif t in ("user/message", "assistant/message", "tool/call"):
                extract_dsh(texts, obj)
    finally:
        f.close()
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
