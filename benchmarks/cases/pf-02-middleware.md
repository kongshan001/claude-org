---
case_id: pf-02
agent: org-pathfinder
topic: middleware-contract
created: 2026-08-30
---
# 用例:多语言寻路中间层方案

- **任务描述**:设计可移植的寻路中间层(支持 JS/Python/C++ 三端),输出接口契约方案
- **验收点**:
  1. 给出 findPath() 接口签名(含 opts → {path, found, stats})
  2. stats 字段含 algorithm/nodesVisited/frontierMax/ms/pathLength
  3. 算法层只问三件事(is_passable/进入代价/邻居),与渲染解耦
  4. 新算法接入方式(注册一个函数,调用方零改动)
- **历史得分**:—(首轮 baseline)
