# bug-patterns 经验沉淀

- 2026-08-30 | 容器首次插入默认值 | "首次插入返回默认值"是最易反复踩的 bug 模式:C++ unordered_map::operator[] 插入默认 0,if(nd < dist[nk]) 变 1<0 永远假,Dijkstra 0% 成功率;ALT dist_matrix 全 0 致启发式变垃圾(A* 退化 Dijkstra 1376→450 节点);同项目出现 3 次(C++ ×2 + JS/Python 同构);规则:任何"首次插入默认值"读写改用 find()/end() 显式检查 | 会话挖掘(3 次实证)
- 2026-08-30 | Array.shift 当堆 = 退化 BFS | Array.shift() 从数组头取最小元素不维护堆序,等于退化成 BFS 遍历;"A* nodesVisited ≈ BFS"是堆实现坏掉的直接信号;修法:写真 MinHeap(binary heap,pop 时跳过 stale entry) | 会话挖掘(JS 重构 bench 铁证)
