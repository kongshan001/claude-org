# cpp-ffi-pitfalls 经验沉淀

- 2026-08-30 | CXX_VISIBILITY_PRESET hidden 藏 extern C | .o 里有符号、.dylib 里没有——visibility hidden 会把 extern "C" 导出也藏掉;nm 排查是定位手段,删掉 visibility 设置解决 | 会话挖掘(实际修复)
- 2026-08-30 | macOS C extension 构建 | CPython C extension 需 -undefined dynamic_lookup;可不用 setuptools 直接 clang 编译(一行 build_native.sh);ctypes 需精确匹配 argtypes,先用 nm 确认导出再写 Python 侧 | 会话挖掘(实际修复)
