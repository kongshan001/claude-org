# agent-org-ops 经验沉淀

- 2026-08-30 | jq 幂等检查 | any(.hooks[]?; cond) 的 generator 相对数组求值恒为空,永远判 false → 用 [.hooks.SessionStart[]? | .hooks[]? | .command? // "" | contains(x)] | any 数组聚合 | install.sh 实测踩坑
- 2026-08-30 | install.sh 备份目录 | *.bak-*/ 内含 SKILL.md 会被 harness 当 skill 扫描进列表 → 备份目录不能留在 ~/.claude/skills/ 下 | 实测 org.bak 被识别
- 2026-08-30 | 系统自举盲区 | 搭建/改造 org 系统的会话内,触发机制未生效,经验不会自动沉淀 → 需显式走 org 协议或下个会话补沉淀 | 本次会话实测
