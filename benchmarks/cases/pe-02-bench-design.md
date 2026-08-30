---
case_id: pe-02
agent: org-perf-engineer
topic: benchmark-methodology
created: 2026-08-30
---
# 用例:基准测试设计方案

- **任务描述**:设计一个跨语言寻路 bench 方案(避免测量陷阱),输出设计
- **验收点**:
  1. 含校准方式(每次调用处理整个数组/用调用次数校准,避免越界)
  2. 含测量顺序约束(冷页函数先测,防预取污染)
  3. 含机制验证手段(反汇编 nm/objdump 确认内联/PLT)
  4. 含内部一致性校验(数量级自洽才算可信)
- **历史得分**:—(首轮 baseline)
