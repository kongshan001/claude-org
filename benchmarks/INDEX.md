# Agent Benchmark 索引

> Agent 迭代回归压测:用例沉淀 → 压测运行 → 盲评打分 → 对比审核。
> 触发:迭代/晋升提案获批后自动附带一轮压测;也可手动"压测 <agent>"。

## 用例库

| 用例 | 路径 | 被测 agent | 状态 |
|---|---|---|---|
| 11 个用例(art×3 + pf/pe/wg/cf×8) | `cases/*.md` | org-game-art / org-pathfinder / org-perf-engineer / org-webgl-dev / org-cpp-ffi | 活跃 |

## 运行记录

| Run | 日期 | 被测 agent | 均分 | 对比 |
|---|---|---|---|---|
| run-001~006 | 2026-08-30 | org-game-art(100×4轮🏅)/ webgl-dev(87.5→100)/ pathfinder(100)/ perf(93.75)/ cpp-ffi(100) | 详见 results.md |

## 规则速查

- 用例格式:`任务描述 / 期望产出 / 验收点(3-5 条,可判定)/ 历史得分`
- 评估:`org-bench-evaluator` 盲评(不看历史分/不看身份),按验收点 0/0.5/1 逐条打分 → 总分 0-100
- 对比:单用例跌幅 > 15 分或均分跌幅 > 5 分 → 🔴 警告 + 根因分析提案(回滚/修正/接受)
- 升高/持平 → 更新 baseline;连续 2 轮升高 → 标记"已验证提升"
- 详细协议见 `~/.claude/skills/org-agent/SKILL.md`(benchmark 章节)
