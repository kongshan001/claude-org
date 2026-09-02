# claude-org — org-agent 经验组织系统

按话题自主沉淀经验、基于经验动态调度 Agent、无匹配角色自动提案创建——所有写入都经用户确认。

## 特性

- **话题沉淀**:对话中发现高置信度经验(结论/踩坑/验证过的方案/决策)时,自动提案,确认后写入对应话题
- **动态调度**:任务按语义匹配角色注册表,命中则 spawn 并注入关联话题经验;无匹配提交角色提案
- **角色晋升**:稳定角色可提案升级为 Claude Code 原生 agent
- **跨设备同步**:经验池和技能以 symlink 挂进 `~/.claude/`,内容活在仓库里,`git pull/push` 即同步
- **人工确认铁律**:一切写入(沉淀/建角色/晋升/改注册表)必须先提案、等确认

## 安装(新设备,零侵入)

**方式一(推荐,模型 + skills):** 开一个 Claude Code 会话,说:

```
部署 org
```

模型读到本仓库的 `org-agent` skill 后,会按"部署协议"自动执行:检查 → `./install.sh`(symlink skill,数据层直接用仓库目录)→ 可选 `./cron-jobs.sh` → `./doctor.sh` 验证 → 汇报。

**方式二(手动):**

```bash
git clone https://github.com/kongshan001/claude-org.git ~/Documents/claude-org
cd ~/Documents/claude-org
./install.sh        # symlink skills/org-agent;数据层直接用仓库目录,不碰 settings.json / CLAUDE.md
./cron-jobs.sh      # 定时任务(可选,日报 08:57 + 周报 周五 09:07)
./doctor.sh         # 健康检查
```

**仓库位置约定**:
- 类 Unix(默认): `~/Documents/claude-org`
- **Windows(默认)**: `C:\Users\admin\agent-org`(Git Bash 路径 `$HOME/agent-org`)
- skill 按顶部路径解析规则动态定位(ORG_ROOT),两平台均可自定义

### 部署原则:零侵入

- **不写 settings.json、不改 CLAUDE.md** —— 用户本地配置零改动
- 能力全部来自 `skills/org-agent/`(模型通过 skill description 感知系统)+ 仓库文件(skill symlink,数据层独立)
- **激活方式**:新会话说触发词即可——`沉淀` / `分工` / `派agent` / `建角色` / `压测` / `日报` / `周报` / `部署 org` / `扫描会话`
- 代价:新会话不自动注入 org 意识,依赖触发词激活(主动使用模式)
- **可选常驻模式**:说"开启常驻",模型按 skill 模板把 2 行常驻提示追加进 `~/.claude/CLAUDE.md`(幂等;说"关闭常驻"即移除)

## Windows 部署

要求:Claude Code + **Git Bash**(无 jq 依赖,最小侵入版不再需要)。

```bash
# Git Bash 中(仓库位于 $HOME/agent-org):
cd $HOME/agent-org
./install.sh        # 自动检测 Windows → 复制模式部署
./cron-jobs.sh      # 定时任务(在 Claude Code 会话环境执行)
./doctor.sh         # 健康检查
```

- **无 symlink 依赖**:Windows 走复制模式,无管理员/开发者模式要求
- **仓库改动后同步**:每次 `git pull` 或修改后,跑 `./sync.sh` 复制到 `~/.claude/`
- Makefile 仅限类 Unix(Windows 直接跑脚本)

## 使用

- 正常聊天即可,识别到经验会自动提案
- 说"沉淀/分工/派agent/建角色/组织agent" → 走 `org` skill 完整协议
- 经验同步:`cd ${ORG_ROOT}(仓库根)&& git add -A && git commit -m "..." && git push`

## 结构

```
claude-org/
├── install.sh               # 幂等安装脚本
├── README.md
├── docs/                    # 设计文档
├── skills/org-agent/SKILL.md      # org 协议 skill
└── org/                     # 数据层(独立目录,不依赖 .claude)
    ├── INDEX.md             # 话题 + 角色总索引(调度入口)
    ├── topics/<话题>/       # experience.md / skills.md / README.md
    └── agents/<角色>.md     # 实验角色定义(稳定后晋升)
```

## 跨设备共享(核心优势)

**经验是仓库里的纯文件,git 就是共享通道** —— 任意设备 clone/pull 即获得全部经验资产。

### 三层同步分工

| 层 | 位置 | 同步方式 | 说明 |
|---|---|---|---|
| **经验数据** | `${ORG_ROOT}/org`(仓库目录,独立于任何平台) | `git push/pull` | 话题经验/角色注册表/用例/压测记录/报告/todo |
| **协议能力** | `~/.claude/skills/` + `~/.agents/skills/`(跨工具公约) | symlink → 仓库 | org-agent skill 随 git 更新即生效 |
| **执行机制** | 各工具各自(CLAUDE.md / ~/.dsh/AGENTS.md 等) | "开启常驻"按协议补 | 一次性配置 |

### 使用流程(设备 A → 设备 B)

```bash
# 设备 A:沉淀经验后同步
cd ${ORG_ROOT} && git add -A && git commit -m "..." && git push

# 设备 B:拉取即用
git pull
# 新会话说"部署 org-agent"(未部署时)→ 或直接说触发词开始使用
```

### 实际效果

- 设备 A 沉淀的踩坑经验 → 设备 B 相关 agent 开工自动读取,不重复踩坑
- 角色验证记录(如 org-game-art 🏅 4 轮满分)→ 设备 B 直接信任,无需重跑压测
- 跨平台互通:macOS 沉淀 → Linux/Windows(`$HOME/agent-org`)pull 即用
- 跨工具互通:同一份经验池,Claude Code / DSH / Codex / Cursor 均可读取调度

### 平台位置约定

| 平台 | 默认路径 |
|---|---|
| macOS/Linux | `~/Documents/claude-org` |
| Windows | `C:\Users\admin\agent-org`(Git Bash:`$HOME/agent-org`) |

## 已知局限

1. **触发式激活**:零侵入部署的代价——新会话不自动注入 org 意识,靠触发词激活(可选用"开启常驻"补常驻提示)
2. **复杂度在模型侧**:协议较厚,但用户只需记 3 个触发词(沉淀/派agent/压测);所有写入先提案确认
3. **平台耦合**:唯一硬依赖是 cc-connect(飞书交付 + cron);经验池/角色/压测全为纯 markdown,可迁移
4. **当前阶段**:方法论验证成功(6 轮压测、2 次缺口修复闭环),但角色池大多处于实验期——生产化靠持续真实使用喂养,而非补功能

## 要求

- Claude Code(2.1.x)
- bash + jq(macOS: `brew install jq`)

## 注意

- hook 对**新会话**生效;旧会话不重触发
- 仓库内不含任何密钥/凭证;`settings.json` 的 env 不会被打包
