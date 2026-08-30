# claude-org — Claude Code 经验组织系统

按话题自主沉淀经验、基于经验动态调度 Agent、无匹配角色自动提案创建——所有写入都经用户确认。

## 特性

- **话题沉淀**:对话中发现高置信度经验(结论/踩坑/验证过的方案/决策)时,自动提案,确认后写入对应话题
- **动态调度**:任务按语义匹配角色注册表,命中则 spawn 并注入关联话题经验;无匹配提交角色提案
- **角色晋升**:稳定角色可提案升级为 Claude Code 原生 agent
- **跨设备同步**:经验池和技能以 symlink 挂进 `~/.claude/`,内容活在仓库里,`git pull/push` 即同步
- **人工确认铁律**:一切写入(沉淀/建角色/晋升/改注册表)必须先提案、等确认

## 安装(新设备)

```bash
git clone https://github.com/kongshan001/claude-org.git ~/Documents/claude-org
cd ~/Documents/claude-org
./install.sh        # 静态配置:org/ + skills/org/ symlink、SessionStart hook、CLAUDE.md
./cron-jobs.sh      # 定时任务:日报(每天08:57)+ 周报(每周五09:07),需在 Claude Code 会话环境执行
```

**约定路径(勿改)**:仓库固定 clone 到 `~/Documents/claude-org`(cron prompt 内引用该路径)。

install.sh(幂等)会:
1. `~/.claude/org/` → symlink 到仓库 `org/`(经验随 git 同步)
2. `~/.claude/skills/org/` → symlink 到仓库 `skills/org/`
3. `settings.json` 合并 SessionStart hook(注入 org 协议 + 角色池,去重)
4. `CLAUDE.md` 追加 org 协议块(去重)

cron-jobs.sh(幂等)会:
1. 按 desc 清理已有同名 cron 任务
2. 部署日报(每天 08:57)+ 周报(每周五 09:07),`--session-mode new-per-run`

完成后**新开一个 Claude Code 会话**即生效。

## 使用

- 正常聊天即可,识别到经验会自动提案
- 说"沉淀/分工/派agent/建角色/组织agent" → 走 `org` skill 完整协议
- 经验同步:`cd ~/Documents/claude-org && git add -A && git commit -m "..." && git push`

## 结构

```
claude-org/
├── install.sh               # 幂等安装脚本
├── claude-md-block.md       # CLAUDE.md 追加块
├── README.md
├── docs/                    # 设计文档
├── skills/org/SKILL.md      # org 协议 skill
└── org/                     # ← symlink 为 ~/.claude/org
    ├── INDEX.md             # 话题 + 角色总索引(调度入口)
    ├── hook-context.md      # 会话启动注入的协议提示
    ├── topics/<话题>/       # experience.md / skills.md / README.md
    └── agents/<角色>.md     # 实验角色定义(稳定后晋升)
```

## 要求

- Claude Code(2.1.x)
- bash + jq(macOS: `brew install jq`)

## 注意

- hook 对**新会话**生效;旧会话不重触发
- 仓库内不含任何密钥/凭证;`settings.json` 的 env 不会被打包
