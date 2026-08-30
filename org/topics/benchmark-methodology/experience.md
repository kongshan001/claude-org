# benchmark-methodology 经验沉淀

- 2026-08-30 | 基准测试四坑 | ①校准变量越界→读越数组末尾 Bus error,改"每次调用处理整个数组、用调用次数校准" ②测量顺序污染:cold_big 先跑会把 cold_small 页预取,首调≈0,须先测单页 ③微基准测不出局部性:稳态小热区全进 L1I,可测的是冷页代价 ④用反汇编验证机制(nm/objdump 确认"确实是 LTO 内联""确实走 PLT") | 会话挖掘(实测撞出)
- 2026-08-30 | 内部一致性校验 | 单页首调 4µs × 900 页 ≈ 4MB 首调 3.6ms,数量级自洽才算可信;寻路 bench 固定配置(200 query/seed=42/距离8..30/radius18)+六维指标(成功率/avg ms/p50/avg nodes/avg path/最优率),结果自动写 docs/latest-bench.md | 会话挖掘
