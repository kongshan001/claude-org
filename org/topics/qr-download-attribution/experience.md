# qr-download-attribution 经验沉淀

- 2026-09-02 | 二维码归因调研 | 静态二维码无法追加埋点:图片内容生成即固定,服务端只能看到"同 URL 被访问 N 次",无法区分扫码者与扫码工具;要来源数据只能弃旧码发新码 | 证据:research/findings.md(演示仓库 qr-scan-attribution 完整论证)
- 2026-09-02 | 方案设计 | 标准方案=渠道专用码 + 归因网关:每渠道一张码、码内带 ?src=渠道ID → 扫码先进网关(识别+落日志)→ 再分发跳转;网易官网实测同款架构(码内带 from=qr) | 证据:B 组逆向 + demo/server.py 可跑
- 2026-09-02 | 识别能力边界 | UA 可识别:平台(iOS/Android/桌面)+ 微信 MicroMessenger/支付宝 AlipayClient/QQ(QQ/·MQQBrowser)/抖音 aweme/钉钉 DingTalk;系统相机直扫 → 默认浏览器 UA 无特征 → **不可溯源**。此盲区是行业共性(网易也只特判微信/微博,不区分支付宝/QQ/抖音) | 证据:demo SCAN_APP_RULES + 网易落地页 JS 解剖
- 2026-09-02 | 分发策略 | 微信/QQ 内置浏览器拦截 Android APK 直下;iOS 微信内不拦 App Store → 安卓扫码须引导"右上角·浏览器打开",该引导本身可作来源佐证埋点;鸿蒙(OpenHarmony)网易作为独立平台发独立包 | 证据:4 UA 实测 + 网易同款处理
- 2026-09-02 | 网易官网取证 | 梦幻西游手游官网(my.163.com)下载码由动态分发网关生成(adl.netease.com/d/g/g18/c/gc/qr),解码内容=网关 URL + from=qr 来源参数——官方渠道归因佐证;官网 iOS/安卓按钮走同网关 ?type=ios/android | 证据:zxing 解码 + 首页 HTML
- 2026-09-02 | 网易分流架构 | 分流=单一落地页+前端 JS 判断:不同 type= 参数返回 md5 完全一致的页面(服务端不分流);UA 规则 isIos=/ipad|iphone|ipod|ios|Mac/i 会误中 Mac,iPad/桌面 Mac 需排除式(!like Mac OS|iphone|ipad)再判 | 证据:4 UA 抓包 + 页面 md5 对比
- 2026-09-02 | 网易防盗链 | APK 直链带 key1/key2 签名,服务端按请求方每次换 key(g18.gdl.netease.com/MY_M-1.575.0.apk?key1=…&key2=…):防链接被抄、防包被篡改;生产上线 APK 直链建议照做 | 证据:同 URL 两次抓包 key 不同
- 2026-09-02 | 网易埋点 | 分发前 iframe 打点(gad.netease.com/mmad/point,point_id 10013~10016 区分"真机/非本平台"4 场景)+ 500ms 延迟跳转确保账记上;iOS 链路走 shark-tracer 302 归因链带设备指纹 shark_id | 证据:落地页 JS 完整解剖 + 端点实测 302
- 2026-09-02 | 工程坑:python http.server | 静态文件 content-type 必须按扩展名映射;PNG 误发 text/plain 时浏览器/IM 客户端拒渲染,表现为"图裂"而 HTTP 200 | 证据:demo/server.py 修复前后对比
- 2026-09-02 | 工程坑:cloudflared | quick tunnel 免账号即公网可达(临时域名);Go resolver 对 argotunnel.com 瞬时 DNS refused 导致注册失败,重试即可通;大陆网络 GitHub release 大文件(54MB)下载超时需 -C - 断点续传 | 证据:隧道注册失败日志 + 续传后 --version 通过
- 2026-09-02 | 工程坑:Git Bash/Windows | Git Bash 的 /tmp 路径对原生 python 进程不可见(相对 cwd 解析失败)——先 cd /tmp 再调 python,或全程用 Windows 绝对路径 | 证据:python FileNotFoundError /tmp/my163-home.html
- 2026-09-02 | 远程演示交付 | 用户不在电脑旁时 localhost/局域网码全部失效:需①cloudflared 公网隧道指向网关 ②按隧道域名重新生成码(动态 /qr/<渠道>.png 按请求 Host 生成即可免重生成) ③码图 URL 公网可达才能进 IM 消息 | 证据:飞书扫码验证全流程
- 2026-09-02 | 决策:仓库布局 | 调研+demo 独立成仓库(d:\claude_code_proj\qr-scan-attribution,与 kb-workflow 平级)避免污染;渠道表 CHANNELS 单源,前端下拉经 /api/meta 下发,杜绝前后端渠道不同步 | 证据:repo 结构 + simulate.html fetch /api/meta
