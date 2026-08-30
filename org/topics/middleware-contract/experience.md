# middleware-contract 经验沉淀

- 2026-08-30 | 寻路中间层契约 | findPath(map, sq, sr, gq, gr, opts) → {path, found, stats, trace?} 永不改动;stats 恒含 algorithm/nodesVisited/frontierMax/ms/pathLength;算法层只问三件事(is_passable/进入代价/6 邻居),与渲染引擎解耦;新算法=注册一个函数,调用方零改动 | 会话挖掘(JS/Python/C++ 三端对齐验证)
- 2026-08-30 | 跨语言对齐行为而非实现 | 跨语言对齐的是行为(算法/seed/接口),不是实现形态;JS class-based 重构在 Node 512MB heap 下 OOM(V8 GC 在 tight loop+类实例分配下清理不及时),回退 function-based + 显式 MinHeap;Python 保留 class;重构成功的判据是行为不变(bench 逐位对齐) | 会话挖掘(OOM 根因定位)
