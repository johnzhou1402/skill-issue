---
name: interview
description: Interview the user about a task before implementation. Use when user says "interview me", "gather requirements", "ask me questions about this", "help me spec this out", or "what questions do you have".
---

# Interview Task

Interview user in detail about the current task before implementation.

## Interview process

Ask probing questions using AskUserQuestion. Cover:

- **Technical implementation** - architecture, APIs, data flow, dependencies
- **UI/UX** - if applicable, user flows, edge cases, error states
- **Scope** - what's in/out, filtering criteria, edge cases
- **Integration** - how it connects to existing systems, what it replaces
- **Failure modes** - what happens when things go wrong
- **Tradeoffs** - performance vs simplicity, flexibility vs speed

**Question guidelines:**
- Ask non-obvious questions (not things easily answered by reading the task)
- Use AskUserQuestion with 2-4 options per question
- Ask 3-4 questions at a time, continue until all areas are covered
- Dig deeper when answers reveal complexity
- When proposing changes, provide context on how the current system handles it
- **Avoid marking options as "(Recommended)"** - present options neutrally to avoid anchoring bias. Only add a recommendation when highly convicted (e.g., clear technical necessity, established codebase pattern). When you do recommend, explain *why* briefly.

## After interview

1. Write a complete spec summarizing what was discussed
2. Include an **Implementation Plan** with numbered steps
3. The spec should be detailed enough that Claude (or another developer) could implement it without asking more questions
