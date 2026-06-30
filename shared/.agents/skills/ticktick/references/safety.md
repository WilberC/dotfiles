# Safety

## Confirmation Matrix

No confirmation normally needed:

- Read-only listing and summaries.
- Narrow reports over user-requested projects or date windows.
- Completing one clearly matched open task when the user says it is done, finished, listo, hecho, completado, terminado, or equivalent English/Spanish/Spanglish phrasing.

Preview first when useful:

- Creating several tasks from a plan.
- Rescheduling multiple tasks.
- Retagging or reprioritizing several tasks.
- Moving tasks across projects.
- Creating project groups, columns, or tags.

Explicit confirmation required:

- Deleting tasks, projects, project groups, comments, habits, or focus records.
- Bulk completing tasks.
- Bulk moving or reorganizing tasks/projects.
- Changing recurrence on existing tasks or habits.
- Any action where multiple candidates match and the target is unclear.

## ID Resolution

- Use project names only after resolving them with `ticktick project list --json`.
- Use task IDs from explicit user input or actual JSON results.
- If multiple projects or tasks match, show a compact candidate list and ask the user to choose.
- Do not use the "first" match unless the sorting rule is stated and the user accepts it.

## Dry-Run Format

For proposed writes, show:

| Action | Item | Project | Date | Priority | Tags |
| --- | --- | --- | --- | --- | --- |

Keep the preview short. For large batches, show a summary plus the highest-risk rows.

## Error Handling

Authentication or missing CLI:

- State that the local `ticktick` CLI is not ready.
- Do not provide install/auth instructions unless asked.

Not found:

- Re-query projects or relevant project data if appropriate.
- Show likely candidates.

Ambiguous:

- Ask the smallest clarifying question needed.
- If the user uses casual English, Spanish, or Spanglish, clarify only when the action or target cannot be resolved confidently from TickTick data.

Partial failure:

- Separate successful changes from failed/skipped ones.
- Include the failed item title, intended action, and short error.

Rate/network/API errors:

- Avoid aggressive retries.
- Explain that the request failed and preserve the user's intended changes as a preview if possible.

## Privacy

- Do not echo sensitive task contents unnecessarily.
- Summarize personal data at the level needed for the request.
- Do not store personal TickTick data in skill files.
- Do not include tokens, cookies, authorization codes, or secrets in responses or files.
