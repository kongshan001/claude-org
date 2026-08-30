---
case_id: cf-02
agent: org-cpp-ffi
topic: cpp-ffi-pitfalls
created: 2026-08-30
---
# 用例:ctypes 对接方案

- **任务描述**:用 ctypes 对接 C++ 寻路库,输出绑定方案
- **验收点**:
  1. 含 argtypes 精确签名匹配(先 nm 确认再写 Python 侧)
  2. 含默认值容器坑的规避(find()/end() 显式检查)
  3. 含批量接口设计(粗粒度 bulk 优于逐元素 getter)
  4. 含构建脚本要点(可直接 clang 编译,无需 setuptools)
- **历史得分**:—(首轮 baseline)
