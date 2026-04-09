# Copilot-Request-Optimizer

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> [🇬🇧 English Version](README_EN.md)

一套可复用的 VS Code Copilot 工作流，让每次交互都以「当前结果 + 下一步选项」收尾，减少高级请求浪费。

## 为什么能省请求

每个 Copilot 高级请求都很宝贵。这套方案通过以下方式减少浪费：

1. **一次请求同时产出结果和下一步分支**，减少「接下来做什么」的额外轮次。
2. **用户直接点选下一步**，不用重新打一大段补充说明。
3. **同一 agent 在同一上下文里连续推进**，减少重开会话的上下文重建。
4. **工具不可用时自动退化为文本选项**，无需额外一轮。
5. **统一 skill 生成选项**，模型不用每轮重新发明交互方式。

## 结构总览

四层配合：

```text
~/.copilot/
├── copilot-instructions.md         ← 第 1 层：全局工作流协议
└── skills/
    └── vscode-next-step-orchestrator/
        └── SKILL.md                ← 第 2 层：配套 skill

~/Library/Application Support/Code/User/
└── prompts/
    ├── vscode-askquestions-global.instructions.md  ← 第 3 层：跨 agent 兜底
    └── interactive-workflow.agent.md               ← 第 4 层：具体 agent
```

| 层 | 模板文件 | 作用 |
|---|---|---|
| 1 | [`copilot-instructions.md`](templates/zh/copilot-instructions.md) | 全局协议：完成任务 → 应用 skill → 调用 ask-questions |
| 2 | [`SKILL.md`](templates/zh/skills/vscode-next-step-orchestrator/SKILL.md) | 生成 1-5 个可执行、非空泛的下一步 |
| 3 | [`vscode-askquestions-global.instructions.md`](templates/zh/vscode-askquestions-global.instructions.md) | 跨 agent 兜底：工具兼容、停止条件、安全确认 |
| 4 | [`interactive-workflow.agent.md`](templates/zh/interactive-workflow.agent.md) | 具体 agent，显式接入 skill |

## 快速开始

### 方式 A：一键安装脚本（macOS）

```bash
git clone https://github.com/westsmiles2405/Copilot-Request-Optimizer.git
cd Copilot-Request-Optimizer
./install.sh
```

脚本会让你选择 English 或中文模板。

### 方式 B：手动配置

#### 第一步：打开 Agent Skills

在 VS Code `settings.json` 中添加（参见 [`examples/settings.json`](examples/settings.json)）：

```json
{
  "chat.useAgentSkills": true,
  "chat.agentSkillsLocations": {
    "~/.copilot/skills": true
  }
}
```

#### 第二步：复制全局 Copilot 指令

```bash
cp templates/zh/copilot-instructions.md ~/.copilot/copilot-instructions.md
```

定义默认交互闭环：完成当前任务 → 应用 skill → 调用 `vscode/askQuestions`。

#### 第三步：复制配套 Skill

```bash
mkdir -p ~/.copilot/skills/vscode-next-step-orchestrator
cp templates/zh/skills/vscode-next-step-orchestrator/SKILL.md \
   ~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md
```

这是整套方案的核心——告诉模型**怎样**生成高质量下一步：总结状态、生成 1-5 个选项、避免空泛兜底项。

#### 第四步：复制 VS Code 用户级 Instructions

```bash
cp templates/zh/vscode-askquestions-global.instructions.md \
   ~/Library/Application\ Support/Code/User/prompts/
```

跨 agent 兜底：保留 agent 角色边界、优先 `vscode/askQuestions`、退化到 `vscode_askQuestions` → `ask_user` → 纯文本。

#### 第五步：复制 Agent 模板

```bash
cp templates/zh/interactive-workflow.agent.md \
   ~/Library/Application\ Support/Code/User/prompts/
```

一个具体的 agent，声明工具列表并在每次提问前显式应用 skill。

## 工具兼容性

把以下名称视为同一工具族：

| 运行时名称 | 优先级 |
|---|---|
| `vscode/askQuestions` | 首选 |
| `vscode_askQuestions` | 降级 |
| `ask_user` | 降级 |
| 纯文本选项 | 最后兜底 |

## 为什么必须分层

| 只用一层 | 问题 |
|---|---|
| 只写全局指令 | 模型知道要提问，但下一步质量不稳定 |
| 只写 skill | 没有入口显式要求，容易被忽略 |
| 只写 agent | 复用性差，每个 agent 都要重复维护 |
| 只用一个工具名 | 运行时一变就失效 |

## 验证清单

1. 在任意 VS Code 对话里发一个明确任务。
2. 检查 agent 是否先完成任务，不是一开始就追问。
3. 收尾时是否出现 1-5 个基于上下文的选项。
4. 选项是否是「动作 + 结果」形式。
5. 是否允许自由输入。
6. 工具不可用时是否退化为纯文本。
7. 输入「停止」「结束」「不要再问」后是否不再追问。

## 项目结构

```text
Copilot-Request-Optimizer/
├── README.md              ← 中文版（默认）
├── README_EN.md           ← English
├── LICENSE
├── install.sh
├── examples/
│   └── settings.json
└── templates/
    ├── copilot-instructions.md               ← English
    ├── vscode-askquestions-global.instructions.md
    ├── interactive-workflow.agent.md
    ├── skills/
    │   └── vscode-next-step-orchestrator/
    │       └── SKILL.md
    └── zh/                                    ← 中文版
        ├── copilot-instructions.md
        ├── vscode-askquestions-global.instructions.md
        ├── interactive-workflow.agent.md
        └── skills/
            └── vscode-next-step-orchestrator/
                └── SKILL.md
```

## 脱敏建议

发布前检查：

- 把绝对路径中的用户名替换成 `~`
- 不要提交 `session-state`、`workspaceStorage`、`globalStorage`、`History`
- Memory 文件只保留示例
- 不要公开真实项目名、工作区路径、私人日志
- `settings.json` 只贴最小必要片段

## 参与贡献

欢迎 Fork 并提交 PR！

1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: 添加某个功能'`)
4. 推送分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## ⭐ If this helps

Give it a star ⭐
你省下的请求次数，值一个 star

## 许可证

[MIT](LICENSE) © 2025
