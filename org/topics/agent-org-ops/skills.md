# agent-org-ops 技能速查

- 安装/升级:clone 仓库 → ./install.sh(幂等,可重复跑)
- 经验同步:git add/commit/push(org/ 是仓库 symlink)
- jq 幂等判断标准写法:`.hooks.X[]? | .hooks[]? | .command? // "" | contains(标记)` 用数组聚合 `[...] | any`
