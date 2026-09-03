# godot-integration 经验沉淀

- 2026-09-01 | 新贴图必须导入 | 新放入项目/替换已导入的 PNG 后必须 `godot --headless --path <proj> --import`，否则 ResourceLoader.exists/load 认不出或读旧缓存；"热加载即生效"只在编辑器运行时成立 | Godot 4.6 实测（树/角色贴图两次踩中）
- 2026-09-01 | albedo 相乘 | StandardMaterial3D 最终色 = albedo_color × albedo_texture（逐通道相乘）：占位纯色材质换贴图时必须 albedo_color=Color.WHITE，否则整图被染色（实测角色贴图变橙红） | 课程项目实测
- 2026-09-01 | SpriteFrames 先建动画 | Godot 4.6 中 add_frame 不会自动创建动画（报 Animation 'x' doesn't exist）；须先 add_animation + set_animation_loop/speed 再逐帧 add_frame；空动画上 play() 不切换，需帧数守卫 | 4.6 实测
- 2026-09-01 | SubViewport 世界获取 | SubViewport.get_world_3d() 返回 null（即使 own_world_3d=true，世界懒创建）；射线查询用视口内任意 Node3D（如碰撞体）的 get_world_3d().direct_space_state | 4.6 实测
- 2026-09-01 | 实例化根名 | 场景实例化的根节点名 = .tscn 里 [node name="X"] 的 X，不是文件名；脚本/测试 get_node 路径按此写 | 多次测试路径踩坑
- 2026-09-02 | flip_h 镜像残留 bug 与通用解法 | flip_h 是节点持久属性，水平移动设置后垂直移动/停止不复位 → "往下跑停后却往左看"；通用模式=单一 facing 状态（left/right/up/down）移动时单源写入，停止/镜像/动画选择全由它推导，垂直移动强制复位镜像；避免"分轴记忆"（水平/垂直各自记忆→跨轴污染） | 2.5D 方向化集成实测
- 2026-09-02 | 多方向动画状态机与优雅降级 | AnimatedSprite2D 按 run_down/run_up/run_side + idle 方向变体组织；某方向缺资产（帧数 0）时运行时回退正面循环；SpriteFrames 空动画 play() 不切换需帧数守卫（机制部分见 SpriteFrames 条目） | 方向批集成实测
- 2026-09-02 | 2.5D 呈现形态 + SubViewport 渲染盒隔离 | 形态决策：3D 胶囊体占位被用户否决（外观诡异）→ 2D 全身立绘经 SubViewport 渲染 + 序列帧动画；动画在渲染盒内部播放，外层 y-sort/对齐/拾取零改动——资产与逻辑解耦，换动画/换皮不改机制 | 课程项目形态演进实测
