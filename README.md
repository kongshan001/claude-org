# claude-org — Claude Code 经验组织系统

按话题自主沉淀经验、基于经验动态调度 Agent、无匹配角色自动提案创建——所有写入都经用户确认。

## 特性

- **话题沉淀**:对话中发现高置信度经验(结论/踩坑/验证过的方案/决策)时,自动提案,确认后写入对应话题
- **动态调度**:任务按语义匹配角色注册表,命中则 spawn 并注入关联话题经验;无匹配提交角色提案
- **角色晋升**:稳定角色可提案升级为 Claude Code 原生 agent
- **跨设备同步**:经验池和技能以 symlink 挂进 `~/.claude/`,内容活在仓库里,`git pull/push` 即同步
- **人工确认铁律**:一切写入(沉淀/建角色/晋升/改注册表)必须先提案、等确认

## 安装(新设备,三步)

```bash
git clone https://github.com/kongshan001/claude-org.git ~/Documents/claude-org
cd ~/Documents/claude-org
make setup          # = install(静态配置)+ crons(定时任务)+ doctor(健康自检)
make doctor         # 随时复查 5 层配置状态(应全绿)
```

**约定路径(勿改)**:仓库固定 clone 到 `~/Documents/claude-org`(cron prompt 与 hook 脚本内引用该路径)。

### 各层配置一览

| 层 | 机制 | 部署方式 | doctor 检查 |
|---|---|---|---|
| 经验池 `org/` | symlink → 仓库(git 同步) | install.sh | ✅ |
| org skill | symlink → 仓库 | install.sh | ✅ |
| SessionStart hook | 仓库 `hooks/org-session-start.sh` 复制到 `~/.claude/hooks/`,settings.json 引用路径 | install.sh | ✅ |
| CLAUDE.md | 追加 2 行瘦身块(指针) | install.sh | ✅ |
| cron 日报/周报 | cron-jobs.sh(幂等) | crons | ✅ |

> 说明:SessionStart hook 是主通道(启动时动态注入 org 协议 + 角色池),CLAUDE.md 是兜底保险丝。hook 逻辑在仓库 `hooks/` 内,可 git 版本化、可单独测试(`echo '{}' | hooks/org-session-start.sh`)。

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
