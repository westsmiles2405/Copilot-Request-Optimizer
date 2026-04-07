# Copilot-Request-Optimizer
# Efficient-Agent-Protocol 🚀

> Reduce Copilot premium request usage by minimizing interaction rounds.
> 通过减少交互轮数，降低 Copilot 高级请求消耗。

---

## 🔥 Why this matters | 为什么重要

### English

**Default Copilot behavior:**

* ❌ Multi-turn clarification loops
* ❌ Repeated follow-up questions
* ❌ Wasted premium requests

**With this project:**

* ✅ Finish tasks in one response whenever possible
* ✅ Provide structured next-step options
* ✅ Reduce unnecessary interaction rounds

👉 **Less interaction = fewer premium requests**

---

### 中文

**默认 Copilot：**

* ❌ 多轮确认
* ❌ 反复追问
* ❌ 浪费高级请求

**使用本方案：**

* ✅ 尽量单轮完成任务
* ✅ 自动生成下一步选项
* ✅ 减少无效交互

👉 **交互越少 = 请求越省**

---

## 🧪 Demo | 示例

### ❌ Before（默认 Copilot）

User:

> 优化这段代码

Copilot:

> 你是想优化性能还是可读性？

👉 又消耗一次请求

---

### ✅ After（本方案）

Copilot:

> 已完成优化（性能 + 可读性）

Next steps:

1. 添加单元测试
2. 转为并发版本
3. 分析时间复杂度
4. 重构为模块化结构

👉 用户直接选择，无需再次输入

---

## 💡 Core Idea | 核心思想

### English

This is NOT just a config.
This is a **protocol** that changes how Copilot interacts:

1. Complete the current task in one shot
2. Generate structured next-step options
3. Let users choose instead of re-asking

---

### 中文

这不是简单配置，而是一套**交互协议**：

1. 当前任务一次性完成
2. 自动生成结构化“下一步”
3. 用选择替代重复提问

---

### 🧠 What it optimizes | 优化点

| Problem 问题                  | Solution 解决方案                |
| --------------------------- | ---------------------------- |
| Too many turns 轮数过多         | One-shot completion 单轮完成     |
| Repeated clarification 重复确认 | Structured next steps 结构化下一步 |
| Context rebuild 上下文重建       | Continuous workflow 连续工作流    |

👉 核心：**减少交互轮数**

---

## ⚡ Quick Start（5分钟上手）

### 1️⃣ Enable Agent Skills

```json
{
  "chat.useAgentSkills": true,
  "chat.agentSkillsLocations": {
    "~/.copilot/skills": true
  }
}
```

---

### 2️⃣ 全局指令

路径：

```text
~/.copilot/copilot-instructions.md
```

```md
# Global Copilot Instructions

1. Always complete the current task first
2. Then generate next-step options
3. Minimize interaction rounds
```

---

### 3️⃣ 添加 Skill

```text
~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md
```

---

### 4️⃣ 添加 Prompt

```text
~/Library/Application Support/Code/User/prompts/
```

---

## 🧩 Reusable Prompt（核心）

```md
You are an efficient task-oriented coding assistant.

Rules:
1. Always fully complete the current task in one response whenever possible.
2. Avoid unnecessary back-and-forth clarification unless strictly required.
3. After completing the task, propose 1–5 concrete next steps as optional actions.
4. Each next step must be actionable and specific (not generic suggestions).
5. If a tool like `askQuestions` is available, use it to present structured choices.
6. If not, present options in plain text.
7. Prioritize minimizing the number of interaction rounds.

Goal:
Reduce the number of user–assistant interaction cycles while maintaining high-quality outputs.
```

---

## 💰 How it saves requests | 如何节约请求

### English

This does NOT change pricing.
It reduces **wasted requests**:

* fewer clarification loops
* fewer repeated prompts
* fewer context rebuilds

---

### 中文

不会改变计费规则，但减少浪费：

* 减少确认轮
* 减少重复提问
* 减少上下文重建

---

### 📊 Impact（效果）

| Scenario    | 轮数  |
| ----------- | --- |
| Default     | 3–6 |
| This method | 1–2 |

👉 **约减少 50–70% 交互轮数**

---

## 🏗 Architecture | 架构

4 层设计：

1. Global Instructions（全局行为）
2. Skill（生成下一步）
3. Agent（执行约束）
4. Prompt（减少交互）

---

## 🔧 Advanced | 进阶

* askQuestions 工具兼容
* fallback 策略
* 多 agent 协作
* skill 编排

---

## ✅ Checklist

* [ ] 单轮完成任务
* [ ] 自动生成下一步
* [ ] 选项可执行
* [ ] 支持降级
* [ ] 可停止

---

## 📌 Key Insight | 关键结论

> This project is not about making Copilot smarter.
> It’s about making it **talk less and do more**.

> 这不是让 Copilot 更聪明，而是让它
> **少说话，多做事**

---

## ⭐ If this helps

Give it a star ⭐
你省下的请求次数，值一个 star
