# qr-download-attribution 可复用技能

## 1. 扫码来源 UA 识别规则表(可直接抄)

匹配顺序即优先级,统一小写比较;不命中 => 相机/第三方工具直扫(默认浏览器),**不可溯源**。

```python
SCAN_APP_RULES = [
    ("micromessenger", "wechat", "微信扫一扫"),
    ("alipayclient",   "alipay", "支付宝扫一扫"),
    ("dingtalk",       "dingtalk", "钉钉扫一扫"),
    ("aweme",          "douyin", "抖音扫一扫"),
    ("qq/",            "qq", "QQ扫一扫"),
    ("mqqbrowser",     "qq", "QQ / QQ浏览器扫一扫"),
]
# 平台: iphone/ipad/ipod -> ios; android -> android; windows/macintosh/linux 同理
# 注意: iOS UA 含 "like Mac OS X" —— 别用 "Mac" 判 Mac; iPadOS 桌面模式 UA 形似 macOS 会误判
```

## 2. cloudflared 免账号公网隧道(三连)

```bash
# 下载(大陆网络建议断点续传)与启动——临时域名,进程停即失效
curl -sL -C - -o cf.exe https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe
./cf.exe tunnel --url http://localhost:8899 --no-autoupdate
# 从日志 grep 出 https://xxx.trycloudflare.com; DNS refused 报错=瞬时,重试即可
```

## 3. 渠道码 + 归因网关 MVP 骨架

最小可跑结构(见 d:\claude_code_proj\qr-scan-attribution):

```
CHANNELS dict(渠道单源) + 落地页 /dl?src=<id> → record(UA识别+JSONL日志) → 按平台渲染分发引导
二维码端点 /qr/<渠道>.png 按请求 Host 动态生成(免维护、局域网/隧道域名自动正确)
模拟扫码 /sim/<app>/<src>: 注入 FAKE_UAS 走同一识别管道(演示/测试同管道)
```

- 识别函数(detect_platform/detect_scan_app)纯逻辑无 IO → 天然可单测
- src 参数白名单 [a-z0-9-] 防注入;日志 JSONL ensure_ascii=False 落盘 + RLock
- 静态服务 content-type 按扩展名映射(.png → image/png),否则 IM/浏览器拒渲染
