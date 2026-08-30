# 对接不同 Coding Agent(Claude Code / DSH / Codex / Cursor …)

org 系统的对接分三层,每层的跨工具策略不同:

| 层 | 内容 | 跨工具策略 |
|---|---|---|
| **协议层** | `org-agent` skill(触发词/铁律/协议) | **SKILL.md 是跨工具开放标准**(agentskills.io)——放到各工具的 skills 目录即被识别 |
| **角色层** | org/agents/ 注册表 → 各工具 agents 目录 | **发布协议**(模型按目标规范渲染写盘) |
| **数据层** | 经验池/角色/用例/报告(纯 markdown) | **任何工具可读**——skill 定义里写"开工读 ~/Documents/claude-org/org/...",绝对路径跨工具有效 |

## 对接矩阵

| 工具 | skills 目录 | agents 目录 | 安装方式 | 状态 |
|---|---|---|---|---|
| **Claude Code** | `~/.claude/skills/`(symlink) | `~/.claude/agents/`(发布) | `./install.sh` + 发布协议 | ✅ 完成 |
| **Codex** | `~/.codex/skills/` 或 `~/.agents/skills/`(公约) | `~/.codex/agents/` | 复制 skill + 发布协议 codex 目标 | ⚙️ 目标已定义 |
| **Cursor** | `.cursor/skills/` + `~/.agents/skills/`(兼容) | `.cursor/agents/` | 同上 cursor 目标 | ⚙️ 目标已定义 |
| **DSH(DeepSeek Harness)** | 插件机制(pnpm workspace) | 插件内定义 | 打包 npm 插件:`dsh plugin --profile <名> add <包>` | 📋 见下 |
| **其他**(OpenCode/Gemini/Copilot…) | `.agents/skills/` 公约 | 各自 agents 目录 | 复制 + 发布协议扩展 | 🔧 按模板 |

## 各工具对接步骤

### 1. Claude Code(已完成,参考实现)

```bash
git clone https://github.com/kongshan001/claude-org.git ~/Documents/claude-org
cd ~/Documents/claude-org && ./install.sh   # symlink org/ + skills/org-agent/
# 角色发布:说"发布 org-game-art" → 模型按规范写盘 ~/.claude/agents/
```

### 2. Codex

```bash
# skill 层:复制(Codex 也认 .agents/skills/ 行业公约)
mkdir -p ~/.codex/skills && cp -R skills/org-agent ~/.codex/skills/
# 或 mkdir -p ~/.agents/skills && cp -R skills/org-agent ~/.agents/skills/
# 角色层:说"发布 org-pathfinder --target codex" → 模型写盘 ~/.codex/agents/
```

Codex 的 SKILL.md frontmatter(name/description)与标准一致,支持实验字段 `allowed-tools`(org 未用,省略即可)。Codex 另读 `AGENTS.md` 作常驻指令——如需常驻,把 `templates/claude-md-always-on.md` 内容追加进 `~/.codex/AGENTS.md`(模型按流程执行)。

### 3. Cursor

```bash
# skill 层:Cursor 2.4+ 原生支持 skills,优先 .cursor/skills/,也读 .agents/skills/
mkdir -p ~/.cursor/skills && cp -R skills/org-agent ~/.cursor/skills/
# 角色层:.cursor/agents/(模型按发布协议渲染)
```

### 4. DSH(DeepSeek Harness)

DSH 是 cordis/pnpm workspace 架构,插件 = npm 包,按 profile 安装:

```bash
# 打包 org-agent 为 DSH 插件(参考 archify 的 @tt-a1i/archify-dsh 模式)
# 包结构:package.json + SKILL.md(+ org/ 数据目录)
dsh plugin --profile web add <本地tarball或npm包名>   # 例如 @kongshan001/org-agent-dsh
```

DSH 特有注意:
- 插件按 profile 隔离(`--profile web|headless`),按需装到对应 profile
- settings.yaml 可配 agent-presets;org 触发词模型侧生效方式同 Claude Code
- 数据层:`org/` 经验池放任意位置,skill 定义里写绝对路径即可

### 5. 新工具接入模板(通用)

1. 查该工具的 skills 目录规范(优先 `.agents/skills/` 公约,否则工具自有目录)
2. 复制 `skills/org-agent/` 到该目录(SKILL.md 标准跨工具)
3. 查 agents 目录 → 在 skill 发布协议的"目标目录"表加一行
4. 验证:该工具会话里说触发词,确认 skill 被识别
5. 常驻可选:按该工具的常驻指令机制(AGENTS.md 等)追加模板

## 能力降级矩阵(Claude Code 特有能力)

| 能力 | Claude Code | 其他工具 |
|---|---|---|
| 飞书交付 | cc-connect send --image | 降级:交付本地文件路径 |
| 日报/周报 cron | cc-connect cron | 降级:手动说"日报"生成 |
| 定时任务 | cc-connect cron | 无(或工具自带调度) |
| 经验池/角色/压测 | ✅ 全量 | ✅ 全量(纯文件,绝对路径可读) |
| 发布到 agents | ✅ | ✅(发布协议多目标) |

**原则**:核心资产(经验/角色/用例/协议)与工具无关,任何工具接上 skill 即可用;只有"交付/定时"这类执行能力随工具降级。
