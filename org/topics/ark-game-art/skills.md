# ark-game-art 技能速查

- 完整工作流:项目 skill `game-asset-gen`(出图/动画/交付/查账全协议)
- 出图:`arkcli +gen --model ep-20260829210909-97w2v --open --save-to /tmp/... "<prompt>"`
- 动画:Seedance I2V → ffmpeg fps=10 抽帧 → GIF(20帧@10fps)/精灵图(xstack 8×1)
- 交付:`cc-connect send --image <path>`(飞书不能发 mp4)
- 查账:`arkcli usage stats --start <date> --endpoint ep-xxx`(root 无 --mine)
