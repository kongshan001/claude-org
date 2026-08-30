---
case_id: pf-01
agent: org-pathfinder
topic: hex-jps
created: 2026-08-30
---
# 用例:hex JPS 移植方案

- **任务描述**:把标准方形网格 JPS 移植到 6 方向 hex 网格,输出移植方案
- **验收点**:
  1. 指出自然后继需从 3 方向扩到 5 方向(d, d±1, d±2)
  2. 指出跳跃点判定用"任意阻挡邻居"而非标准 side blocked
  3. 指出路径重建需补全跳跃点间缺失的中间 hex
  4. 说明 JPS 适用边界(均匀成本;weighted 用 A*)
- **历史得分**:—(首轮 baseline)
