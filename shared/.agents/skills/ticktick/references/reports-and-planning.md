# Reports And Planning

## Data Windows

Use explicit windows for reports:

- Today: local start/end of the current date.
- This week: local week range; state the exact dates.
- Recently completed: default to the last 7 days if the user does not specify.
- Upcoming: default to the next 7 days if the user does not specify.
- Focus records: query at most 30 days per request because TickTick focus API ranges are limited.

## Daily Status

Gather:

1. Projects with `ticktick project list --json`.
2. Relevant project data with `ticktick project data <projectId> --json`.
3. Completed tasks for today or requested range.
4. Habits and focus records if the user asks for personal status, energy, routines, or what they did.

Report:

- Overdue tasks.
- Due today.
- Scheduled or started today.
- High-priority open work.
- Recently completed work.
- Suggested next 3 actions.

## Weekly Review

Gather completed tasks, open high-priority tasks, overdue tasks, upcoming due dates, habits, and focus records.

Report:

- Wins: completed work grouped by project or tag.
- Carry-over: important unfinished tasks.
- Risks: overdue/high-priority items and overloaded dates.
- Suggested plan: a short sequence for the next week.

## Prioritization Heuristics

Rank tasks higher when they are:

- Overdue.
- Due today or tomorrow.
- Priority `5` high, then `3` medium, then `1` low, then `0` none.
- Blocking a project or parent task.
- Repeatedly deferred or stale.
- Related to recent focus or active habits.

Rank lower when they are:

- Unscheduleable due to missing context.
- Low priority and not time-sensitive.
- Duplicates or stale ideas.

## Calendar-Like Planning

TickTick task dates are not a full external calendar. Build calendar-like plans from `startDate`, `dueDate`, `isAllDay`, recurrence, habits, and focus records.

When scheduling:

- Convert relative dates to concrete dates.
- Preserve all-day intent when the user says "sometime today" or gives only a date.
- Use timed tasks when the user gives a time or duration.
- Avoid assigning too many high-priority tasks to the same day.
- Ask before changing recurrence.

## "What Did I Do?"

Use:

```bash
ticktick task completed --projects <projectId> --start-date "<from>" --end-date "<to>" --json
ticktick focus list --from "<from>" --to "<to>" --type 0 --json
ticktick focus list --from "<from>" --to "<to>" --type 1 --json
ticktick habit checkins --habits <habitIds> --from <YYYYMMDD> --to <YYYYMMDD> --json
```

Summarize output by result, not by raw command:

- Completed tasks.
- Focus time or pomodoros.
- Habits checked in.
- Notable missed routines or unfinished commitments.

## "What Do I Need To Do?"

Use project data and filters to build a clear action list:

- Due/overdue first.
- Then high-priority unscheduled tasks.
- Then quick maintenance such as adding dates/tags to ambiguous tasks.

End with a concrete recommendation, for example: "Do these three first", "Schedule these two", or "Confirm whether to defer these."
