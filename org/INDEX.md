# org 经验组织系统 — 总索引

> 本文件是调度入口。新任务进来时:按任务语义匹配 `agents/` 角色;无匹配则提交角色提案。
> 所有写入操作(沉淀/建角色/晋升/修改)必须先经用户确认。

## 话题清单

| 话题 | 路径 | 触发关键词 | 状态 |
|---|---|---|---|
| 火山方舟游戏美术管线 | `topics/ark-game-art/` | 生图、精灵图、Q版、动画、序列帧、Seedream、Seedance、飞书 | 活跃 |
| org 系统自身运维 | `topics/agent-org-ops/` | org、install.sh、hook、幂等、自举 | 活跃 |
| 寻路性能 | `topics/pathfinding-perf/` | FFI、marshaling、DLL、优化杠杆、ALT | 会话挖掘 |
| 基准测试方法论 | `topics/benchmark-methodology/` | 微基准、校准、测量顺序、反汇编 | 会话挖掘 |
| hex JPS 寻路 | `topics/hex-jps/` | JPS、hex、跳跃点、六边形 | 会话挖掘 |
| WebGL 渲染 | `topics/webgl-rendering/` | WebGL、BLEND、截图、像素回归、自验收 | 会话挖掘 |
| Bug 模式 | `topics/bug-patterns/` | 默认值、堆、map、shift、退化 | 会话挖掘 |
| C++/FFI 构建 | `topics/cpp-ffi-pitfalls/` | visibility、dylib、ctypes、nm、C extension | 会话挖掘 |
| DSH 插件 | `topics/dsh-plugins/` | dsh 插件、dsh-restart、bundle、插件安装、重启、更新检查 | 活跃 |
| 中间层契约 | `topics/middleware-contract/` | 契约、接口、多语言对齐、重构 | 会话挖掘 |
| 二维码下载归因 | `topics/qr-download-attribution/` | 扫码、二维码、渠道归因、埋点、下载网关、UA 识别、MicroMessenger、落地页分流 | 活跃 |
| Godot 引擎集成 | `topics/godot-integration/` | Godot、导入、.import、材质、albedo、SpriteFrames、SubViewport、资产验收 | 活跃 |

## 角色清单

| 角色 | 路径 | 专长 | 状态 |
|---|---|---|---|
| org-coordinator | `agents/org-coordinator.md` | 编排:拆解/匹配/派发/质检/提案(无写盘权) | 实验期 |
| org-todo-organizer | `agents/org-todo-organizer.md` | 待办整理:识别/提案/维护 org/todo.md | 实验期 |
| org-bench-evaluator | `agents/org-bench-evaluator.md` | 压测评估:盲评打分/验收点判定 | 实验期 |
| org-dsh-plugins | `agents/org-dsh-plugins.md` | DSH 插件:调研/安装/安全核对/重启更新/挂载验证 | 实验期 |
| org-general-executor | `agents/org-general-executor.md` | 通用兜底:按任务规格书执行,无专长 | 内置 |
| org-game-art | `agents/org-game-art.md` | 2D 游戏美术资产:生图/动画/飞书交付 | 🏅 已验证(3轮压测) |
| org-pathfinder | `agents/org-pathfinder.md` | 寻路算法(hex JPS/A*)/多语言移植/中间层契约 | 会话挖掘 |
| org-perf-engineer | `agents/org-perf-engineer.md` | FFI/DLL 性能优化/benchmark 方法论 | 会话挖掘 |
| org-webgl-dev | `agents/org-webgl-dev.md` | WebGL 渲染/像素验收/交付自验 | 会话挖掘 |
| org-cpp-ffi | `agents/org-cpp-ffi.md` | C++ 构建/导出符号/ctypes 对接 | 会话挖掘 |

## 命名规则

- **`org-` 前缀 = 本系统沉淀的 Agent**:凡 org 经验沉淀的角色,命名一律 `org-<name>`;外部安装/下载的 agent 命名空间我们不碰
- 旧名映射:game-art-agent→org-game-art;general-executor→org-general-executor;bench-evaluator→org-bench-evaluator;todo-organizer→org-todo-organizer(历史引用对照用)

## 使用协议

- **主会话 = 纯编排者**:只做拆解/匹配/派发/质检/提案;有产出物的任务必须派发(org-general-executor 兜底),纯对话直接答;agent 失败降级须提案用户
- **沉淀**:对话中识别高置信度内容 → 提出建议条目 → 用户确认 → 写入 `topics/<slug>/experience.md`
- **调度**:任务 → 匹配角色 → spawn(注入关联话题经验)→ 完成后经验回写(需确认)
- **建角色**:org-general-executor 同类工作 ≥2 次 → 角色提案 → 用户批准 → 创建 `agents/<slug>.md`
- **晋升**:稳定角色 → 提案 → 批准 → 拷贝到 `~/.claude/agents/`(harness 原生)
- 详细协议见 `~/.claude/skills/org-agent/SKILL.md`
