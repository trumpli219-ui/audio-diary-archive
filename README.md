# 音频日记归档 Skill

把录音笔 U 盘 `RECORDER` 文件夹中的 `Note-YYYYMMDDHHMMSS.mp3` 复制到 `YYYY年M月/D日` 文件夹，并检查副本大小。源录音默认保留。

## 一条命令安装

先安装 Node.js（自带 npm / npx）及 Git，在终端执行：

```sh
npx --yes skills add trumpli219-ui/audio-diary-archive -g -y
```

安装器会发现本机支持的 Agent，使用用户级共享 Skills 目录及相应链接。默认采用链接方式，不需要逐个复制技能。安装器说明见 [vercel-labs/skills](https://github.com/vercel-labs/skills)。安装后新开一个 Agent 对话。

需要明确指定 Codex / Claude Code 时：

```sh
npx --yes skills add trumpli219-ui/audio-diary-archive -g -a codex claude-code -y
```

未被安装器识别的工具，需要将其技能发现目录连接到公用目录中的 `audio-diary-archive`，或通过工具的“导入本地 Skill”功能导入该目录。不能保证所有 Agent 自动识别。

## 首次使用

**实际归档仅支持 Windows。** 在 macOS 上可以安装和查看技能，但不能运行 Windows 盘符归档流程。

1. 告诉 Agent：`使用音频日记归档技能，我的保存目录是 D:\我的音频日记。`
2. Agent 将你确认的路径写入技能目录的 `scripts/config.txt`。也可以自己填写一行绝对路径；注释和空行会被忽略。
3. 插入录音笔，确认盘符 E 到 L 中有 `RECORDER` 文件夹，再说：`帮我归档录音。`
4. 查看复制数量与校验结果。程序不会自动删除 U 盘录音。

已进入技能对话时：`1` 归档；`2` 请求 Agent 自检；`3` 请求清理（需要确认具体文件）。脚本只实现归档与大小校验，自检与清理由 Agent 按 SKILL.md 执行。

## 使用边界

- 仅扫描 E 到 L 盘根目录下的 `RECORDER`，找到第一个即使用；多个录音设备请先只连接要处理的那个。
- 只处理直接位于该文件夹、文件名符合规则的 mp3，不递归子文件夹。
- 同名目标文件按原工作流由源录音覆盖，请使用专用归档目录。
- 当前校验比较文件大小，不是内容哈希验证。
- 清理需逐项核对副本并由用户确认，不得删除未归档文件。
- 更新技能前备份 `scripts/config.txt`，安装更新可能覆盖配置。

## 来源与发布整理

原始材料：用户提供的 `scripts.zip`，原 README 署名王济帆，说明来自 QClaw 工作流并迁移至 WorkBuddy。本仓库保留此来源说明，不代表获得原作者额外授权或官方适配认证。

本次整理：标准化 Skill 元数据；修复配置注释被当成目标路径的问题；取消默认猜测目标盘符；复制显式使用 `/Y` 与原流程覆盖语义一致；限定数字触发上下文；去掉无差别批量删除示例；补充一条命令安装说明。
