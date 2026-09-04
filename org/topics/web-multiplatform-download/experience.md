# web-multiplatform-download 经验沉淀

- 2026-09-04 | 多平台兼容分析方法论 | 四步逆向链路:①curl 多 UA 探重定向(-sI 看 301/Location,PC/移动双向路由)②playwright 多 UA 实渲染(新 context 设 UA+isMobile,观察最终 URL/按钮/遮罩)③抓页面 JS 函数清单(function xxx / var is_xx)定位分流逻辑 ④提取 URL 常量与平台变量赋值(ios_link/android_link 等)拼全证据链;证据分级:服务端 301(强)> 页面静态内容(中)> JS 逻辑(中强)> 点击行为(需实机) | 梦幻西游官网实测
- 2026-09-04 | 网易(梦幻西游)多平台兼容架构案例 | 三层分流:①PC站 my.163.com ↔ 移动站 /m/ 服务端 301 按 UA 双向往返 ②下载短链 adl → 单页多 Tab 落地页(android/ios/harmony/weixin),JS UA 选 Tab:Android 直下 APK(gdl CDN+签名参数)、OpenHarmony 独立检测+鸿蒙专用包(版本号都不同)、iOS 走埋点(shark-tracer)后跳转、微信/微博内置浏览器各有专门 Tab ③PC 桌面版用 navigator.userAgentData.getHighEntropyValues(['architecture','bitness']) 按 CPU 架构给包(arm/win32/win64/mac);iOS 在 PC 上:检测 .plist 企业分发 → 请求服务端 /ipa 代理接口下载 ipa;无包场景 showNoPackage 降级 | 实测逆向(HTML+JS 全量)
- 2026-09-04 | 头部厂商多平台兼容三特征 | ①鸿蒙是独立平台(非 Android 子集:独立 UA 检测+独立包)②PC 端用 UA-CH API 取架构信息(比 UA 字符串猜架构先进)③内置浏览器(微信/微博)特判 + 点击全程埋点(shark-tracer);通用启示:多平台站点应做"服务端路由 + 单落地页多 Tab + 失败降级",而非纯响应式 | 案例归纳
