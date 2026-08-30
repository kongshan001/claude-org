# claude-org — Claude Code 经验组织系统

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

模型读到本仓库的 `org-experience` skill 后,会按"部署协议"自动执行:检查 → `./install.sh`(只做 symlink)→ 可选 `./cron-jobs.sh` → `./doctor.sh` 验证 → 汇报。

**方式二(手动):**

```bash
git clone https://github.com/kongshan001/claude-org.git ~/Documents/claude-org
cd ~/Documents/claude-org
./install.sh        # 只做 symlink(org/ + skills/org-experience/),不碰 settings.json / CLAUDE.md
./cron-jobs.sh      # 定时任务(可选,日报 08:57 + 周报 周五 09:07)
./doctor.sh         # 健康检查
```

**约定路径(勿改)**:仓库固定 clone 到 `~/Documents/claude-org`(cron prompt 引用该路径)。

### 部署原则:零侵入

- **不写 settings.json、不改 CLAUDE.md** —— 用户本地配置零改动
- 能力全部来自 `skills/org-experience/`(模型通过 skill description 感知系统)+ 仓库文件(symlink 同步)
- **激活方式**:新会话说触发词即可——`沉淀` / `分工` / `派agent` / `建角色` / `压测` / `日报` / `周报` / `部署 org` / `扫描会话`
- 代价:新会话不自动注入 org 意识,依赖触发词激活(主动使用模式)
- **可选常驻模式**:说"开启常驻",模型按 skill 模板把 2 行常驻提示追加进 `~/.claude/CLAUDE.md`(幂等;说"关闭常驻"即移除)

## Windows 部署

要求:Claude Code + **Git Bash**(无 jq 依赖,最小侵入版不再需要)。

```bash
# Git Bash 中进入仓库目录:
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
- 经验同步:`cd ~/Documents/claude-org && git add -A && git commit -m "..." && git push`

## 结构

```
claude-org/
├── install.sh               # 幂等安装脚本
├── README.md
├── docs/                    # 设计文档
├── skills/org-experience/SKILL.md      # org 协议 skill
└── org/                     # ← symlink 为 ~/.claude/org
    ├── INDEX.md             # 话题 + 角色总索引(调度入口)
    ├── topics/<话题>/       # experience.md / skills.md / README.md
    └── agents/<角色>.md     # 实验角色定义(稳定后晋升)
```

## 要求

- Claude Code(2.1.x)
- bash + jq(macOS: `brew install jq`)

## 注意

- hook 对**新会话**生效;旧会话不重触发
- 仓库内不含任何密钥/凭证;`settings.json` 的 env 不会被打包
