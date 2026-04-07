# Copilot-Request-Optimizer
# VS Code `vscode/askQuestions` Global Workflow with a Companion Skill

## 中文版

### 可直接复用 Prompt

#### 1. 全局 Copilot 指令模板

文件路径：

```text
~/.copilot/copilot-instructions.md
```

```md
# 全局 Copilot 指令

## 默认交互闭环

将每轮已完成的互动整理成：

1. 当前结果
2. 明确的下一步入口

## 工作流

默认对每个用户请求遵循以下顺序：

1. 先完成当前这一轮必须完成的回答、分析、修改或结论。
2. 再应用 `vscode-next-step-orchestrator` skill。
3. 如果可用，再调用 `vscode/askQuestions`。
4. 如果只有 `vscode_askQuestions` 或 `ask_user`，将其视为兼容降级入口。
5. 如果这些工具都不可用，则输出 1-5 个纯文本下一步选项，并允许用户自由输入。

## 选项规则

- 默认给 3-4 个选项。
- 每个选项都要以动作开头，并描述明确结果。
- 不要加入“其他”或“自定义”，因为自由输入已经存在。
- 只有在用户明确说“ok, stop”“stop”“end”“停止”“结束”或“不要再问”时，才跳过后续提问。

## 安全规则

- 删除、覆盖、重置、批量替换等破坏性操作前必须确认。
```

#### 2. VS Code 全局 Instructions 模板

文件路径：

```text
~/Library/Application Support/Code/User/prompts/vscode-askquestions-global.instructions.md
```

```md
---
description: "VS Code 跨任务共享交互规则，提供 ask-questions 兼容与安全的下一步引导。"
applyTo: "**"
---

# VS Code 共享 ask-questions 规则

这个文件只负责共享交互规则。
它不能替代各个 agent 自己的角色、任务边界、输出格式或领域工作流。

## 共享规则

1. 先完成当前轮任务，再决定是否进入下一步引导。
2. 如果可用，优先使用 `vscode/askQuestions`。
3. 将 `vscode_askQuestions` 和 `ask_user` 视为兼容降级入口。
4. 如果工具不可用，则提供 1-5 个纯文本下一步选项。
5. 默认给 3-4 个选项，除非更适合 1-2 个或 5 个。
6. 选项必须贴合当前上下文，并且可直接执行。
7. 不要把“其他”或“自定义”写成选项，因为自由输入已经存在。
8. 破坏性操作前必须确认。

## 停止条件

如果用户明确说“ok, stop”“stop”“end”“停止”“结束”或“不要再问”，则不要再强制追加下一步问题。
```

#### 3. 配套 Skill 模板

文件路径：

```text
~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md
```

```md
---
name: vscode-next-step-orchestrator
description: "为 VS Code 对话生成 1-5 个可执行的下一步选项，并与 ask-questions 工具族配合使用。"
user-invocable: false
---

# VS Code 下一步编排器

在每次 ask-questions 风格工具调用前，先应用这个 skill。

## 目标

把当前对话状态整理成：

- 一段简短的当前状态总结
- 1-5 个具体的下一步选项
- 一个仍然允许自由输入的后续提问

## 必要工作流

1. 用 1-2 句简短的话总结当前状态。
2. 从真实上下文中推断最有价值的下一步。
3. 生成 1-5 个选项。
4. 默认给 3-4 个选项。
5. 只有接近二选一时才用 1-2 个选项。
6. 只有在确实存在 5 条明显不同的分支时才用 5 个选项。
7. 保持自由输入开启。

## 选项规则

- 每个选项都必须以动作开头。
- 每个选项都必须是当前就能执行的。
- 避免使用“继续”“了解更多”“其他”这种空泛选项。
- 保持选项之间互相区分。

## 工具族兼容

把以下名称视为同一工具族：

- `vscode/askQuestions`
- `vscode_askQuestions`
- `ask_user`

如果可用，永远优先使用 `vscode/askQuestions`。

## 停止条件

只有在用户明确说“ok, stop”“stop”“end”“停止”“结束”或“不要再问”时，才跳过后续提问。

## 降级策略

如果工具不可用，则用纯文本输出同样的选项，并明确告诉用户可以直接输入任何自定义下一步。
```

#### 4. 通用 Agent 模板

文件路径：

```text
~/Library/Application Support/Code/User/prompts/interactive-workflow.agent.md
```

```md
---
name: "交互式工作流 Agent"
description: "适用于引导式工作流、分步交互、下一步导航和结构化追问。"
tools:
  - ask_user
  - "vscode/askQuestions"
  - "vscode/memory"
  - "vscode/runCommand"
  - read
  - search
  - edit
  - execute
user-invocable: true
---

# 交互式工作流 Agent

你是一个面向任务推进的交互式 agent。

## 默认行为

1. 先完成当前轮任务。
2. 不要为了提问而打断关键分析或执行。
3. 每次后续提问前，先应用 `vscode-next-step-orchestrator`。
4. 然后在可用时调用 `vscode/askQuestions`。
5. 如果只有 `vscode_askQuestions` 或 `ask_user`，则将其作为兼容降级入口使用。
6. 如果工具不可用，则提供 1-5 个纯文本下一步选项。

## 选项设计

- 默认给 3-4 个选项。
- 保持选项贴合上下文且可执行。
- 不要包含“其他”或“自定义”。

## 安全

破坏性改动前先确认。
```

### 最小配置片段

```json
{
  "chat.useAgentSkills": true,
  "chat.agentSkillsLocations": {
    ".github/skills": true,
    ".claude/skills": true,
    "~/.copilot/skills": true,
    "~/.claude/skills": true
  }
}
```

### 这份方案是做什么的

这是一套可复用的 VS Code Copilot 工作流，用来让自定义 agent 在每轮任务完成后，默认进入“当前结果 + 下一步按钮”的闭环，并兼容不同运行时里同类工具的不同名字：

- `vscode/askQuestions`
- `vscode_askQuestions`
- `ask_user`

重点不是让模型多问问题，而是让每一次高价值交互尽量完整，减少无效追问、减少重复开新轮对话、减少重复总结上下文。

### 为什么它能帮助节约 Copilot 高级请求次数

这套方法不会改变 GitHub 的计费逻辑，但它能减少很多原本可以避免的高价值请求浪费：

1. 一次请求同时产出“当前结果 + 下一步分支”，减少“那接下来做什么”的额外轮次。
2. 用户可以直接点选下一步，而不是重新打一大段补充说明。
3. 同一个 agent 可以在同一个上下文里连续推进，减少重开会话后的上下文重建成本。
4. 如果工具不可用，会自动退化为文本选项，避免因为工具缺失而重新问一轮。
5. 通过统一的 skill 生成选项，可以减少模型每轮都重新发明交互方式的浪费。

简单说，它节约的不是平台“必然计费多少”，而是你本来会浪费掉的那些来回对话。

### 结构总览

这套方案由四层配合：

1. `settings.json` 打开 Agent Skills 能力。
2. `~/.copilot/copilot-instructions.md` 规定全局行为。
3. `~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md` 提供配套 skill。
4. `~/Library/Application Support/Code/User/prompts/` 目录承载全局 instructions 和具体 agent。

### 配置步骤

#### 第一步：打开 Agent Skills

要让 VS Code 愿意加载用户目录下的 skill，关键是：

- `chat.useAgentSkills: true`
- `chat.agentSkillsLocations` 里启用了 `~/.copilot/skills`

没有这一步，后面的自定义 skill 就算写好了，VS Code 也不一定会识别。

#### 第二步：写全局 Copilot 指令

文件路径：

```text
~/.copilot/copilot-instructions.md
```

这个文件负责定义跨任务、跨会话尽量都成立的默认协议。它不负责具体业务，而负责规定整套工作流应当如何收尾。

核心思路可以概括为一句话：

> 先完成当前轮任务，再通过 skill + ask-questions 工具把下一步入口补齐。

#### 第三步：新增配套 Skill

文件路径：

```text
~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md
```

这个 skill 是整套方案的核心。全局指令只是在说“要做这件事”，skill 才负责“具体怎么做这件事”。

它的职责主要包括：

1. 在每次 ask-questions 风格工具调用前先整理当前状态。
2. 生成 1-5 个真正可执行的下一步。
3. 约束选项不要空泛、不要重复、不要出现“其他/自定义”这类兜底项。
4. 兼容 `vscode/askQuestions`、`vscode_askQuestions`、`ask_user`。

#### 第四步：增加 VS Code 用户级全局 Instructions

文件路径：

```text
~/Library/Application Support/Code/User/prompts/vscode-askquestions-global.instructions.md
```

这一层不是重复 skill，而是做跨 agent 的兜底约束，例如：

- 不破坏已有 agent 的角色边界。
- 不破坏已有 skill 要求。
- 优先使用 `vscode/askQuestions`。
- 对兼容名 `vscode_askQuestions` 和 `ask_user` 做降级兼容。
- 工具不可用时自动退化为纯文本选项。
- 删除、覆盖、重置、批量替换等破坏性操作必须先确认。
- 用户明确说“停止 / 结束 / 不要再问”时停止追问。

#### 第五步：在具体 Agent 中显式接入

如果只写全局规则，很多时候效果不够稳定。所以还要在具体 agent 里显式声明两件事：

1. 工具列表里包含 ask-questions 家族工具。
2. agent 主体里明确要求“先应用 `vscode-next-step-orchestrator`，再调用 ask-questions 工具”。

### 最小可复现结构

```text
~/.copilot/
├── copilot-instructions.md
└── skills/
    └── vscode-next-step-orchestrator/
        └── SKILL.md

~/Library/Application Support/Code/User/
└── prompts/
    ├── vscode-askquestions-global.instructions.md
    └── interactive-workflow.agent.md
```

### 为什么必须分层

如果只写一个 Prompt，通常会遇到这些问题：

1. 只写全局指令，模型知道要提问，但不会稳定地产出高质量下一步。
2. 只写 skill，没有入口文件显式要求使用它，skill 很容易被忽略。
3. 只写 agent，复用性差，而且每个 agent 都要重复维护。
4. 只依赖某一个工具名，运行时一变就可能失效。

### 验证清单

可以用下面这份清单检查配置是否真的生效：

1. 在任意 VS Code 对话里发一个明确任务。
2. 检查 agent 是否先完成当前任务，而不是一开始就追问。
3. 检查收尾时是否出现 1-5 个基于上下文的下一步选项。
4. 检查选项是否是“动作 + 结果”的形式。
5. 检查是否允许自由输入。
6. 在 ask-questions 工具不可用时，检查是否自动退化为纯文本选项。
7. 输入“停止”“结束”“不要再问”后，检查是否不再强制追问。

### 发布到 GitHub 前的脱敏建议

如果准备公开这套方案，建议：

1. 把绝对路径中的用户名替换成 `~`。
2. 不要提交 `session-state`、`workspaceStorage`、`globalStorage`、`History` 等运行时目录。
3. Memory 文件只保留示例，不直接公开本机生成内容。
4. 不要公开真实项目名、工作区路径、私人截图、日志原文。
5. 如果要贴 `settings.json`，只贴最小必要片段。

### 中文小结

这套方法本质上是把 `vscode/askQuestions` 变成一个可复用的工作流协议：用全局指令规定默认闭环，用 skill 生成高质量下一步，用用户级 instructions 保证兼容与兜底，再用具体 agent 把它落到实际任务上。它一个非常现实的目标，就是尽量节约 Copilot 高级请求次数。

---

## English Version

### Reusable Prompts

#### 1. Global Copilot Instructions Template

File path:

```text
~/.copilot/copilot-instructions.md
```

```md
# Global Copilot Instructions

## Default Interaction Loop

Turn each completed interaction into:

1. the current result
2. a clear next-step entry

## Workflow

By default, follow this order for every user request:

1. Finish the current answer, analysis, edit, or conclusion.
2. Apply the `vscode-next-step-orchestrator` skill.
3. Call `vscode/askQuestions` if it is available.
4. If only `vscode_askQuestions` or `ask_user` is available, treat it as a compatible fallback.
5. If none of these tools are available, provide 1-5 plain-text next-step options and allow freeform input.

## Option Rules

- Default to 3-4 options.
- Each option must start with an action and describe a concrete result.
- Do not include "Other" or "Custom" because freeform input already exists.
- Skip the follow-up question only when the user explicitly says "ok, stop", "stop", "end", "不要再问", or an equivalent instruction.

## Safety

- Ask for confirmation before destructive operations such as delete, overwrite, reset, or bulk replace.
```

#### 2. Global VS Code Instructions Template

File path:

```text
~/Library/Application Support/Code/User/prompts/vscode-askquestions-global.instructions.md
```

```md
---
description: "Cross-task shared interaction rules for VS Code agents. Shared ask-questions compatibility and safe next-step guidance."
applyTo: "**"
---

# VS Code Shared Ask-Questions Rules

This file defines shared interaction rules only.
It must not replace each agent's own role, task boundary, output format, or domain-specific workflow.

## Shared Rules

1. Finish the current turn first, then decide whether to offer next-step guidance.
2. Prefer `vscode/askQuestions` when it is available.
3. Treat `vscode_askQuestions` and `ask_user` as compatible fallbacks.
4. If the tool is unavailable, provide 1-5 plain-text next-step options.
5. Default to 3-4 options unless there is a stronger reason for 1-2 or 5.
6. Keep the options contextual and executable.
7. Do not add "Other" or "Custom" as an option because freeform input already exists.
8. Ask for confirmation before destructive operations.

## Stop Condition

If the user clearly says "ok, stop", "stop", "end", "停止", "结束", or "不要再问", do not force another next-step question.
```

#### 3. Companion Skill Template

File path:

```text
~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md
```

```md
---
name: vscode-next-step-orchestrator
description: "Generate 1-5 executable next-step options for VS Code conversations and pair them with the ask-questions tool family."
user-invocable: false
---

# VS Code Next Step Orchestrator

Use this skill immediately before every ask-questions style tool call.

## Goal

Turn the current conversation state into:

- a short current-state summary
- 1-5 concrete next-step options
- a follow-up question that still allows freeform input

## Required Workflow

1. Summarize the current state in 1-2 short sentences.
2. Infer the most useful next steps from the real conversation state.
3. Produce 1-5 options.
4. Default to 3-4 options.
5. Only use 1-2 when the decision is near-binary.
6. Only use 5 when there are five clearly different branches.
7. Keep freeform input enabled.

## Option Rules

- Each option must start with an action.
- Each option must be executable now.
- Avoid vague choices like "continue", "learn more", or "other".
- Keep the options mutually distinct.

## Tool Family Compatibility

Treat the following names as the same family:

- `vscode/askQuestions`
- `vscode_askQuestions`
- `ask_user`

Always prefer `vscode/askQuestions` when available.

## Stop Condition

Skip the follow-up question only when the user explicitly says "ok, stop", "stop", "end", "停止", "结束", or "不要再问".

## Fallback

If the tool is unavailable, output the same options as plain text and explicitly tell the user they can type any custom next step.
```

#### 4. Generic Agent Template

File path:

```text
~/Library/Application Support/Code/User/prompts/interactive-workflow.agent.md
```

```md
---
name: "Interactive Workflow Agent"
description: "Use when: guided workflow, step-by-step interaction, next-step navigation, structured follow-up."
tools:
  - ask_user
  - "vscode/askQuestions"
  - "vscode/memory"
  - "vscode/runCommand"
  - read
  - search
  - edit
  - execute
user-invocable: true
---

# Interactive Workflow Agent

You are a task-oriented interactive agent.

## Default Behavior

1. Finish the current task first.
2. Do not interrupt critical analysis or execution only to ask a question.
3. Before each follow-up question, apply `vscode-next-step-orchestrator`.
4. Then call `vscode/askQuestions` if available.
5. If only `vscode_askQuestions` or `ask_user` is available, use it as a compatible fallback.
6. If the tool is unavailable, provide 1-5 plain-text next-step options.

## Option Design

- Default to 3-4 options.
- Keep them contextual and actionable.
- Do not include "Other" or "Custom".

## Safety

Ask for confirmation before destructive changes.
```

### Minimal Settings Snippet

```json
{
  "chat.useAgentSkills": true,
  "chat.agentSkillsLocations": {
    ".github/skills": true,
    ".claude/skills": true,
    "~/.copilot/skills": true,
    "~/.claude/skills": true
  }
}
```

### What This Setup Does

This is a reusable VS Code Copilot workflow that makes custom agents end each completed turn with a compact loop: current result plus structured next-step options. It also preserves compatibility across different runtime names for the same family of tools:

- `vscode/askQuestions`
- `vscode_askQuestions`
- `ask_user`

The goal is not to make the model ask more questions. The goal is to make each high-value interaction more complete, so you waste fewer turns on repeated clarifications, repeated restarts, and repeated context rebuilding.

### Why It Helps Save Copilot Premium Requests

This setup does not change GitHub's billing logic, but it reduces waste that would otherwise consume premium requests:

1. A single request can produce both the current result and the next-step branches.
2. The user can click the next step instead of typing a long follow-up from scratch.
3. The same agent can continue within the same context, so you rebuild context less often.
4. If the tool is unavailable, the workflow degrades to plain-text options instead of forcing another round.
5. A shared skill standardizes the follow-up behavior, so the model does not waste turns reinventing the interaction pattern every time.

In short, this setup does not guarantee any billing outcome. It reduces avoidable conversational waste.

### Architecture Overview

This setup works because four layers support each other:

1. `settings.json` enables Agent Skills.
2. `~/.copilot/copilot-instructions.md` defines the global workflow.
3. `~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md` provides the companion skill.
4. `~/Library/Application Support/Code/User/prompts/` stores global instructions and concrete agents.

### Setup Steps

#### Step 1: Enable Agent Skills

The two critical lines are:

- `chat.useAgentSkills: true`
- enabling `~/.copilot/skills` inside `chat.agentSkillsLocations`

Without this, your custom skill may exist on disk but still not be recognized by VS Code.

#### Step 2: Add Global Copilot Instructions

File path:

```text
~/.copilot/copilot-instructions.md
```

This file defines a default protocol across tasks and sessions. It does not own task-specific behavior. It defines how the workflow should close each turn.

Core idea:

> Finish the current turn first, then use the skill plus the ask-questions tool to offer the next step.

#### Step 3: Add the Companion Skill

File path:

```text
~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md
```

This skill is the heart of the setup. Global instructions only say that the workflow should do this. The skill defines how to do it well.

Its main responsibilities are:

1. Summarize the current state before every ask-questions style call.
2. Generate 1-5 genuinely executable next steps.
3. Prevent vague, repetitive, or catch-all options.
4. Preserve compatibility with `vscode/askQuestions`, `vscode_askQuestions`, and `ask_user`.

#### Step 4: Add a VS Code User-Level Global Instructions File

File path:

```text
~/Library/Application Support/Code/User/prompts/vscode-askquestions-global.instructions.md
```

This layer adds cross-agent guardrails, for example:

- keep each agent's own role boundaries intact
- do not weaken existing skill requirements
- prefer `vscode/askQuestions`
- support compatible fallbacks like `vscode_askQuestions` and `ask_user`
- degrade to plain-text options when the tool is unavailable
- require confirmation before destructive actions
- stop the follow-up loop when the user explicitly asks to stop

#### Step 5: Explicitly Hook It into Concrete Agents

Global rules alone are often not stable enough. So each concrete agent should explicitly declare:

1. the tool list includes the ask-questions family
2. the agent body says to apply `vscode-next-step-orchestrator` before using the ask-questions tool

### Minimal Reproducible Structure

```text
~/.copilot/
├── copilot-instructions.md
└── skills/
    └── vscode-next-step-orchestrator/
        └── SKILL.md

~/Library/Application Support/Code/User/
└── prompts/
    ├── vscode-askquestions-global.instructions.md
    └── interactive-workflow.agent.md
```

### Why This Must Be Layered

If you only write one prompt, you usually hit these problems:

1. with global instructions only, the model knows it should ask something, but the next steps are often low quality
2. with a skill only, the skill is easy to ignore if no entry file explicitly requires it
3. with agent-only logic, reuse is weak and every agent becomes repetitive to maintain
4. if you rely on one tool name only, the setup becomes fragile when the runtime surface changes

### Validation Checklist

Use this checklist to verify that the setup really works:

1. send a clear task in any VS Code chat
2. confirm that the agent finishes the current task before asking a follow-up
3. confirm that the response ends with 1-5 context-aware next-step options
4. confirm that the options follow an action-plus-result pattern
5. confirm that freeform input is still allowed
6. when the ask-questions tool is unavailable, confirm that the setup falls back to plain-text options
7. after typing "stop", "end", "停止", "结束", or "不要再问", confirm that the system stops forcing follow-up questions

### Sanitization Tips Before Publishing to GitHub

If you plan to publish this setup, I recommend:

1. replace usernames in absolute paths with `~`
2. do not commit runtime directories such as `session-state`, `workspaceStorage`, `globalStorage`, or `History`
3. keep only sample memory snippets instead of publishing actual local memory files
4. avoid exposing real project names, workspace paths, private screenshots, or raw logs
5. if you show `settings.json`, keep only the minimal required snippet

### English Summary

At its core, this method turns `vscode/askQuestions` into a reusable workflow protocol: global instructions define the loop, the skill generates high-quality next steps, user-level instructions provide compatibility and guardrails, and concrete agents apply the protocol to real tasks. One very practical goal of this design is to help conserve Copilot premium requests.

## ⭐ If this helps

Give it a star ⭐
你省下的请求次数，值一个 star
