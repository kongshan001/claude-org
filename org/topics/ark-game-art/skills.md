# ark-game-art 技能速查

- 完整工作流:项目 skill `game-asset-gen`(出图/动画/交付/查账全协议)
- 出图:`arkcli +gen --model ep-20260829210909-97w2v --open --save-to /tmp/... "<prompt>"`
- 动画:Seedance I2V → ffmpeg fps=10 抽帧 → GIF(20帧@10fps)/精灵图(xstack 8×1)
- 交付:`cc-connect send --image <path>`(飞书不能发 mp4)
- 查账:`arkcli usage stats --start <date> --endpoint ep-xxx`(root 无 --mine)

## 成本估算规范(v2,2026-08-30 从角色文件外移)

- 任何方案必须给出成本量级估算(区间 + 依据)
- 单价缺失时:给出基于同类模型的区间 + 标注"待实测",禁止只写"事后核账"
- 已知单价:Seedream 5.0 Lite **0.22 元/张**(2K,实测 8 张 1.76 元);Seedance 2.5 I2V **≤1 元/条**(5s 720p,实测 108900 tokens,目录价 0.042-0.07 双口径,精确金额待分账后核对)
