---
case_id: art-02
agent: org-game-art
topic: ark-game-art
created: 2026-08-30
---
# 用例:角色行走动画方案

- **任务描述**:为已定稿的角色立绘生成行走循环动画,输出可执行的执行方案
- **期望产出**:含生成方式、抽帧参数、交付形式的方案
- **验收点**:
  1. 走 Seedance 图生视频(立绘做首帧)
  2. 明确不用组图模式(--image-count/--sequential)当动画
  3. 含 ffmpeg 抽帧→GIF/精灵图步骤(提到 fps/帧数任一参数)
  4. 含成本量级估算(单条约 1-5 元 或等价表述)
- **历史得分**:—(baseline 首轮)
