---
case_id: pe-01
agent: org-perf-engineer
topic: pathfinding-perf
created: 2026-08-30
---
# 用例:FFI 性能优化方案

- **任务描述**:Python 经 FFI 调 C++ 库性能差,输出优化方案(含杠杆排序)
- **验收点**:
  1. 指出性能大头是 FFI marshaling 而非算法
  2. 推荐 stateful handle(消除每次 marshal)或 batch 摊薄
  3. 警告大地图/大数据量下 ctypes 可能比纯 Python 慢
  4. 给出优化杠杆排序(FFI > 算法选型 > 微优化 > 预处理)
- **历史得分**:—(首轮 baseline)
