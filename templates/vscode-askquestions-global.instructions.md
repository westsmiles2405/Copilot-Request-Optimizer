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
