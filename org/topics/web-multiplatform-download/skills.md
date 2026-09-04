# web-multiplatform-download 技能速查

- UA 探测:`curl -sI -A "<UA>" -m 15 <url> | grep -iE "^HTTP|^location"`(UA 模板:PC/iPhone/Android/微信 MicroMessenger)
- 落地页 JS 逆向:`curl -s -A "<UA>" <url> > page.html` → grep 函数清单/URL 常量/平台变量赋值
- playwright 多 UA:`browser.newContext({ userAgent, viewport, isMobile })` 逐 UA 观察最终 URL/按钮/遮罩
- 平台检测正则速查:android=/android/i、harmony=/OpenHarmony/i、微信=MicroMessenger、微博=weibo
- 架构级:UA-CH API `navigator.userAgentData.getHighEntropyValues(['architecture','bitness'])`
