---
name: ticktick
description: Personal TickTick assistant for using an already-installed and already-authenticated `ticktick` CLI to inspect, report on, plan, create, update, complete, move, organize, and safely manage tasks, projects, tags, habits, focus records, comments, countdowns, and calendar-like schedules. Use when the user asks in English, Spanish, or mixed Spanglish what they need to do, what they did, what is overdue/upcoming, how to prioritize, how to organize their TickTick life/work data, says something is done/finished, or asks for CRUD-style TickTick changes. Assumes install and auth are manual; do not use for TickTick CLI installation or login setup unless the user explicitly asks.
---

# TickTick Assistant

## Operating Context

Act as a personal assistant over the user's TickTick data. Treat TickTick as the task and planning source of truth, but do not invent missing IDs, projects, tasks, calendar events, habits, or personal facts.

Assume the `ticktick` CLI is already installed and authenticated. If a command fails because the CLI or auth is unavailable, report that manual setup is needed and stop; do not walk through installation or login unless the user explicitly requests it.

Use `--json` for data gathering and internal reasoning. Convert raw JSON into concise summaries, decisions, and next actions for the user.

## Personal Context

Before answering requests that depend on the user's personal TickTick conventions, aliases, recurring workflows, or preferred organization, check for local context files under `personal-context/` in this skill folder. That folder is intentionally git-ignored and may contain private notes such as list names, course mappings, task naming conventions, or personal project structure. Read only the files that are relevant to the current request, and treat those notes as hints to verify against live TickTick data rather than as guaranteed current state.

Do not store personal TickTick context, list names, task names, project IDs, or private workflow details in the tracked skill files. Keep reusable, public TickTick behavior in this skill and its tracked references; keep user-specific facts in `personal-context/`.

## Default Workflow

1. Classify the request:
   - Status/report: inspect data and summarize what matters.
   - Planning/advice: inspect relevant data, identify constraints, recommend a plan.
   - CRUD/write: resolve IDs, preview meaningful changes, then execute if safe.
   - Natural-language task intent: treat casual English, Spanish, or Spanglish updates as possible task actions.
   - Completion intent: when the user says a task is done, finished, listo, hecho, completado, terminado, or similar, resolve the matching open task and complete it if unambiguous.
   - Destructive/bulk: preview targets and require explicit confirmation.
2. Gather only the needed TickTick data with CLI commands.
3. Resolve names to IDs from actual JSON results. Never guess IDs.
4. Normalize relative dates to concrete dates using the user's timezone.
5. Return an assistant-style answer: what matters, why it matters, and what to do next.
6. For writes, report exactly what changed and any failures.

## Read Relevant References

- `references/assistant-mode.md`: Read for personal-assistant behavior, decision style, context handling, and response shape.
- `references/reports-and-planning.md`: Read for daily/weekly reports, "what do I have to do", "what did I do", prioritization, calendar-like planning, and workload analysis.
- `references/cli-operations.md`: Read before running TickTick CLI commands for tasks, projects, groups, columns, tags, comments, habits, focus, or countdowns.
- `references/data-model.md`: Read when interpreting JSON fields, dates, priorities, statuses, reminders, recurrence, project data, habits, or focus records.
- `references/safety.md`: Read before write, bulk, destructive, ambiguous, or error-prone actions.
- `personal-context/`: If present, read relevant git-ignored local notes when the user asks about their personal TickTick setup, names a personal alias, or references known-but-private organization details.

## Core Rules

- Prefer the official `ticktick` CLI over direct OpenAPI calls.
- Use direct OpenAPI documentation only to understand what is possible or how CLI JSON maps to TickTick data.
- Do not expose raw command output unless the user asks; summarize it.
- Do not delete, bulk-complete, bulk-move, or reorganize without explicit confirmation.
- For ambiguous task/project names, show candidates and ask the user to choose.
- Understand common English, Spanish, and mixed phrasing for task state changes; ask only when the target or action is unclear.
- Interpret "child list", "nested list", "sublist", "sub-list", or "list inside another list" as a TickTick project/list inside a project group/folder unless live data shows a more specific task hierarchy. Resolve this by checking `ticktick project group list --json` and matching projects from `ticktick project list --json` by `groupId`.
- For assistant reports, be decisive but traceable: mention the data window and criteria used.
- Keep personal inferences labeled as inferences, not facts.

## Common Starting Commands

Use these as probes, depending on the request:

```bash
ticktick project list --json
ticktick project data <projectId> --json
ticktick task filter --projects <projectId> --status 0 --json
ticktick task completed --projects <projectId> --start-date "<from>" --end-date "<to>" --json
ticktick habit list --json
ticktick focus list --from "<from>" --to "<to>" --type 0 --json
```

Run narrower commands when the user names a project, tag, date range, or task.
