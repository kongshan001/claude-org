# webgl-rendering 经验沉淀

- 2026-08-30 | WebGL 忘开 BLEND | 忘调 gl.enable(gl.BLEND) 时 shader 对 alpha 的写入在合成到默认 framebuffer 时被静默丢弃,效果视觉与 None 无异且已交付;grep 不到 BLEND/blendFunc 是铁证,交付截图 md5 全同是硬证据;此类问题只有像素回归测试能立刻抓出 | 会话挖掘(web-uieffect 复刻,md5×3)
- 2026-08-30 | WebGL 截图姿势 | Playwright locator.screenshot() 对 WebGL canvas 常抓空白帧;正确姿势:页面内 canvas.toDataURL() 取像素 + preserveDrawingBuffer: true 才能在非绘制帧读回内容 | 会话挖掘
- 2026-08-30 | 交付前必须自验收 | 录屏/gif"看起来正常"不能替代自验收:自查实锤 3 个 bug(_centerView 存 raw 像素而非 world 单位、transform 顺序错、snapshot 同错);图形/渲染类交付没有自动化校验时交付物可能是坏的 | 会话挖掘(用户质疑后自查)
