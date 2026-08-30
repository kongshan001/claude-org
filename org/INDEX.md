# org 经验组织系统 — 总索引

> 本文件是调度入口。新任务进来时:按任务语义匹配 `agents/` 角色;无匹配则提交角色提案。
> 所有写入操作(沉淀/建角色/晋升/修改)必须先经用户确认。

## 话题清单

| 话题 | 路径 | 触发关键词 | 状态 |
|---|---|---|---|
| 火山方舟游戏美术管线 | `topics/ark-game-art/` | 生图、精灵图、Q版、动画、序列帧、Seedream、Seedance、飞书 | 活跃 |
| org 系统自身运维 | `topics/agent-org-ops/` | org、install.sh、hook、幂等、自举 | 活跃 |

## 角色清单

| 角色 | 路径 | 专长 | 状态 |
|---|---|---|---|
| general-executor | `agents/general-executor.md` | 通用兜底:按任务规格书执行,无专长 | 内置 |
| game-art-agent | `agents/game-art-agent.md` | 2D 游戏美术资产:生图/动画/飞书交付 | 实验期 |

## 使用协议

- **主会话 = 纯编排者**:只做拆解/匹配/派发/质检/提案;有产出物的任务必须派发(general-executor 兜底),纯对话直接答;agent 失败降级须提案用户
- **沉淀**:对话中识别高置信度内容 → 提出建议条目 → 用户确认 → 写入 `topics/<slug>/experience.md`
- **调度**:任务 → 匹配角色 → spawn(注入关联话题经验)→ 完成后经验回写(需确认)
- **建角色**:general-executor 同类工作 ≥2 次 → 角色提案 → 用户批准 → 创建 `agents/<slug>.md`
- **晋升**:稳定角色 → 提案 → 批准 → 拷贝到 `~/.claude/agents/`(harness 原生)
- 详细协议见 `~/.claude/skills/org/SKILL.md`
