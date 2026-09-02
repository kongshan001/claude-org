# dsh-plugins 经验沉淀

- 2026-09-01 | dsh 插件调研 | dsh-plugin topic 是插件身份目录;GitHub 无 token 时 topic search API 403,用 web_search 兜底仍可完整发现生态(awesome 列表、npm 包、官方讨论),npm registry 直接 fetch 不受 GitHub 限流 | 证据:本次发现 dsh-restart / dsh-smart-restart / deepseek-ai/deepseek-harness#2717
- 2026-09-01 | dsh-restart 插件评估 | 成熟 bundle 插件:设置页「立即重启」按钮 + /restart 命令 + restart_harness 工具 + 可选看门狗;POST /plugins/dsh-restart/restart 仅接受环回同源;只写 $DSH_HOME(dsh-process.json/dsh-resume.json/看门狗脚本);零运行时依赖、无 install 脚本,安全核对通过 | 证据:npm registry manifest + GitHub 源码
- 2026-09-01 | 安装坑:PATH | dsh plugin 内部跑 profile 的 pnpm,受限 shell PATH 缺 /usr/bin 时因 git ENOENT 失败(profile 含 github: 依赖 @oil-oil/dsh-vision);git 在 macOS 绝对路径 /usr/bin/git | 证据:prod CLI 报 spawn git ENOENT、exit 254
- 2026-09-01 | 安装坑:CLI 原子性 | dsh plugin add 在 pnpm 失败时不会写回 package.json(deps/bundles 保持原样),可安全转手工等价操作:dependencies + dsh.profile.bundles 末尾追加 + profile 目录 pnpm install(PATH 补 /usr/bin);bundles 顺序即 patch 应用顺序 | 证据:失败后检查 package.json 无 dsh-restart
- 2026-09-01 | 生效机制 | 新 bundle 插件必须整进程重启才加载;「热载」只对已加载插件的 patch 改动生效;host 半挂载验证 = 探测其路由(GET /plugins/dsh-restart/restart → 404 即未加载);profile peer 依赖警告(react/cordis)是常态,运行时由 dsh 提供可忽略 | 证据:装后探测 404
- 2026-09-01 | 重启机制:孤儿进程自重生 | dsh web 常以孤儿进程运行(PPID=1 无看门狗),重启必须自重生:detached helper 先 SIGTERM 旧进程 → 轮询端口释放 → 同 argv 重拉 + 日志落盘;spawn(detached:true, stdio:'ignore', unref()) 的子进程在父进程死后存活(实测 marker 验证通过) | 证据:~/.dsh/dsh-restart-bootstrap.mjs + detached 存活测试
- 2026-09-01 | 版本更新检查 | 本地 dsh-update-tab(file: 挂载)工作正常:GET /dsh-update-tab/status 返回 {local, latest, outdated},npmmirror→npmjs 双 registry 探测;版本比较需处理 prerelease(-rc.N 排序低于同号正式版);实测 local=latest=0.1.1-rc.2 已最新 | 证据:实测 status 接口 200
- 2026-09-01 | 生态结论 | 官方「插件更新生命周期与重启扩展服务」仍在讨论 #2717 建议阶段,dev 仓库无内置 restart;社区 dsh-restart 是最优现成解,与 dsh-update-tab 互补(更新检查 + 重启按钮各司其职) | 证据:dev 仓库 grep 无 restart 实现
