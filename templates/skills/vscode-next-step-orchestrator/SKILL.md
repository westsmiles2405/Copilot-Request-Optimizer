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
