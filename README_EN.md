# Copilot-Request-Optimizer

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> [🇨🇳 中文版](README.md)

A reusable VS Code Copilot workflow that makes every turn end with **current result + next-step options**, reducing wasted premium requests.

## Why

Each premium Copilot request is expensive. This setup reduces waste by:

1. Producing both the answer and the next-step branches in a single turn.
2. Letting users click the next step instead of typing a long follow-up.
3. Keeping the same context alive — fewer session restarts, less context rebuilding.
4. Falling back to plain text when the tool is unavailable — no extra round needed.
5. Standardizing follow-up behavior via a shared skill — the model stops reinventing the pattern.

## Architecture

Four layers work together:

```text
~/.copilot/
├── copilot-instructions.md         ← Layer 1: global workflow protocol
└── skills/
    └── vscode-next-step-orchestrator/
        └── SKILL.md                ← Layer 2: companion skill

~/Library/Application Support/Code/User/
└── prompts/
    ├── vscode-askquestions-global.instructions.md  ← Layer 3: cross-agent guardrails
    └── interactive-workflow.agent.md               ← Layer 4: concrete agent
```

| Layer | File | Role |
|-------|------|------|
| 1 | [`copilot-instructions.md`](templates/copilot-instructions.md) | Global protocol: finish task → apply skill → call ask-questions |
| 2 | [`SKILL.md`](templates/skills/vscode-next-step-orchestrator/SKILL.md) | Generate 1-5 executable, non-vague next steps |
| 3 | [`vscode-askquestions-global.instructions.md`](templates/vscode-askquestions-global.instructions.md) | Cross-agent guardrails, tool compatibility, stop conditions |
| 4 | [`interactive-workflow.agent.md`](templates/interactive-workflow.agent.md) | Concrete agent that wires everything together |

## Quick Start

### Option A: Run the Install Script (macOS)

```bash
git clone https://github.com/westsmiles2405/Copilot-Request-Optimizer.git
cd Copilot-Request-Optimizer
./install.sh
```

The script will ask you to choose English or Chinese templates.

### Option B: Manual Setup

#### Step 1: Enable Agent Skills in VS Code

Add to your `settings.json` (see [`examples/settings.json`](examples/settings.json)):

```json
{
  "chat.useAgentSkills": true,
  "chat.agentSkillsLocations": {
    "~/.copilot/skills": true
  }
}
```

#### Step 2: Copy Global Copilot Instructions

```bash
cp templates/copilot-instructions.md ~/.copilot/copilot-instructions.md
```

Defines the default interaction loop: finish the current task → apply the skill → call `vscode/askQuestions`.

#### Step 3: Copy the Companion Skill

```bash
mkdir -p ~/.copilot/skills/vscode-next-step-orchestrator
cp templates/skills/vscode-next-step-orchestrator/SKILL.md \
   ~/.copilot/skills/vscode-next-step-orchestrator/SKILL.md
```

This is the core of the setup. It tells the model **how** to generate high-quality next steps: summarize state, produce 1-5 options, avoid vague or catch-all choices.

#### Step 4: Copy VS Code User-Level Instructions

```bash
cp templates/vscode-askquestions-global.instructions.md \
   ~/Library/Application\ Support/Code/User/prompts/
```

Cross-agent guardrails: preserve agent boundaries, prefer `vscode/askQuestions`, fall back to `vscode_askQuestions` → `ask_user` → plain text.

#### Step 5: Copy the Agent Template

```bash
cp templates/interactive-workflow.agent.md \
   ~/Library/Application\ Support/Code/User/prompts/
```

A concrete agent that declares the tool list and explicitly applies the skill before every follow-up.

## Tool Compatibility

The workflow treats these names as one family:

| Runtime Name | Priority |
|---|---|
| `vscode/askQuestions` | Preferred |
| `vscode_askQuestions` | Fallback |
| `ask_user` | Fallback |
| Plain text options | Last resort |

## Why It Must Be Layered

| Approach | Problem |
|---|---|
| Global instructions only | Model knows to ask, but next steps are low quality |
| Skill only | No entry point requires it — easily ignored |
| Agent only | Poor reuse, every agent repeats the logic |
| Single tool name only | Breaks when the runtime surface changes |

## Validation Checklist

1. Send a clear task in any VS Code chat.
2. Confirm the agent finishes the task before asking a follow-up.
3. Confirm the response ends with 1-5 context-aware next-step options.
4. Confirm options follow an action-plus-result pattern.
5. Confirm freeform input is still allowed.
6. When `vscode/askQuestions` is unavailable, confirm plain-text fallback.
7. After typing "stop" / "end" / "不要再问", confirm no more forced follow-ups.

## File Structure

```text
Copilot-Request-Optimizer/
├── README.md              ← Chinese (default)
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

## Sanitization Tips

Before publishing your own fork:

- Replace usernames in absolute paths with `~`
- Don't commit `session-state`, `workspaceStorage`, `globalStorage`, `History`
- Keep only sample memory snippets
- Don't expose real project names, workspace paths, or private logs
- Show only the minimal `settings.json` snippet

## License

[MIT](LICENSE) © 2025
