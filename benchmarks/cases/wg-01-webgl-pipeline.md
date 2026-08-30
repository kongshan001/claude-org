---
case_id: wg-01
agent: org-webgl-dev
topic: webgl-rendering
created: 2026-08-30
---
# 用例:WebGL 滤镜管线方案

- **任务描述**:实现 WebGL 滤镜/特效管线(含混合、截图验收),输出方案
- **验收点**:
  1. 包含 gl.enable(gl.BLEND) 等状态初始化检查
  2. 含像素回归测试(防"效果假装存在"类 bug)
  3. 截图方案用 canvas.toDataURL() + preserveDrawingBuffer
  4. 含交付前自验收步骤
- **历史得分**:—(首轮 baseline)
