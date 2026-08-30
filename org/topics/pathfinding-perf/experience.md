# pathfinding-perf 经验沉淀

- 2026-08-30 | FFI marshaling 是性能大头 | 跨语言调用性能瓶颈是 FFI 桥接而非算法:ctypes 缓存 flat arrays 4-12× → batch 一次调用摊薄 5-14× → native.stateful 持 C++ 句柄消除 FFI 6-13×;750k hex 大地图上 ctypes 反而比纯 Python 慢(每次 marshal 6.75MB);cffi 仅比 ctypes 快 2-5% 不值引入 | 会话挖掘(demo1 寻路项目 200 query bench)
- 2026-08-30 | DLL 拆分边界成本 | 单次跨模块调用纯边界 ~0.5ns;大头是:内联消失(同 TU 2.27ns vs 跨 dylib PLT 2.80ns)、LTO 跨模块失效、细粒度接口放大(逐元素 2.75ns vs bulk 0.58ns,4.7×)、冷页(单页 4µs/900 页 3.6ms)、加载线性放大 8.9×;dlsym 每次 145ns=52× 是反模式 | 会话挖掘(bench_dll_split,反汇编验证)
- 2026-08-30 | 优化杠杆排序 | ①消除 FFI marshaling(5-10×)>②算法选型 JPS vs A*(2-5×,看地形)>③算法层微优化(5×)<④预处理(1-10× 依赖地形,常被噪声淹没);小数据集不做评测(噪声淹没差异) | 会话挖掘(项目总结)
- 2026-08-30 | ALT 负结果 | 常规地图上 ALT 不赢 plain A*(0.06×~1.03×):hex 距离已是 tight lower bound、每 expand 8 landmark 开销 ~30-50ns、per-query 重算未缓存、ctypes marshaling 1.9MB alt_data 占大头;赢的场景=大型稀疏障碍(1-2% 墙)/走廊地图 + CPython C extension;预处理前先确认启发式 gap 存在 | 会话挖掘(4-way bench)
