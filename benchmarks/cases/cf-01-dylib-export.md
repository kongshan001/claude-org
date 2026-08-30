---
case_id: cf-01
agent: org-cpp-ffi
topic: cpp-ffi-pitfalls
created: 2026-08-30
---
# 用例:C++ dylib 导出方案

- **任务描述**:C++ 库要导出 extern "C" 符号给 Python ctypes 用,输出构建/导出方案
- **验收点**:
  1. 指出 CXX_VISIBILITY_PRESET hidden 会藏 extern C 符号
  2. 含 nm 验证导出符号步骤
  3. macOS 含 -undefined dynamic_lookup 处理
  4. 含导出符号清单核对(避免 .o 有 .dylib 无)
- **历史得分**:—(首轮 baseline)
