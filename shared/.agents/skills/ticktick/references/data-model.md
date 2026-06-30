# Data Model

## Dates

TickTick API-shaped dates use strings like:

```text
yyyy-MM-dd'T'HH:mm:ssZ
```

Example:

```text
2026-03-10T09:00:00+0000
```

Use the user's local timezone unless the user names another timezone or existing task data uses a specific timezone that should be preserved.

## Task Fields

Important task JSON fields:

- `id`: task identifier.
- `projectId`: owning project.
- `title`: short task title.
- `content`: main body for normal text/note-like tasks.
- `desc`: checklist description.
- `startDate`: scheduled start.
- `dueDate`: due/end date; if different from `startDate`, treat it as a time span.
- `timeZone`: task timezone.
- `isAllDay`: all-day flag.
- `priority`: `0` none, `1` low, `3` medium, `5` high.
- `status`: `0` open, `2` completed; some API-shaped data may use `-1` for abandoned.
- `completedTime`: completion timestamp.
- `tags`: tag names.
- `items`: checklist items.
- `columnId` / `columnName`: kanban placement.
- `parentId` / `childIds`: task hierarchy.
- `focusSummaries`: estimated and actual focus metadata.
- `repeatFlag`: recurrence string.
- `reminders`: reminder trigger strings.
- `kind`: commonly `TEXT`, `TASK`, `NOTE`, or `CHECKLIST` depending on source.
- `etag`: server concurrency metadata.

## Project Fields

Important project JSON fields:

- `id`: project identifier.
- `name`: project display name.
- `color`: project color.
- `sortOrder`: sidebar order.
- `closed`: closed/archive state.
- `groupId`: project group/folder.
- `viewMode`: `list`, `kanban`, or `timeline`.
- `permission`: `read`, `comment`, or `write`.
- `kind`: `TASK` or `NOTE`.

`project data` returns:

- `project`: project metadata.
- `tasks`: incomplete tasks in the project.
- `columns`: kanban columns.

## Checklist Items

Checklist item fields:

- `id`: item identifier.
- `title`: item title.
- `status`: `0` not done, `1` done.
- `sortOrder`: item order.
- `startDate`, `isAllDay`, `timeZone`, `completedTime`: optional scheduling/completion metadata.

## Reminders

Reminder strings use `TRIGGER` format. Common examples:

- `TRIGGER:-PT60M`: 60 minutes before.
- `TRIGGER:-P1DT2H`: 1 day and 2 hours before.
- `TRIGGER;RELATED=END:-PT15M`: 15 minutes before the end time.
- `TRIGGER:PT0S`: at the reference time.

Do not invent complex reminder strings if a simple due date is enough. Ask when reminder timing is ambiguous.

## Recurrence

Use one recurrence string:

- `RRULE:FREQ=DAILY`
- `RRULE:FREQ=WEEKLY;BYDAY=MO,WE`
- `ERULE:NAME=CUSTOM;BYDATE=20260325,20260330`

Do not mix `RRULE` and `ERULE` in one value. Ask before changing an existing recurrence.

## Habits

Important habit fields:

- `id`, `name`, `iconRes`, `color`, `sortOrder`, `status`.
- `goal`, `step`, `unit`.
- `repeatRule`, `reminders`.
- `completedCycles`, `etag`.

Habit check-in queries use `YYYYMMDD` dates.

## Focus

Focus types:

- `0`: Pomodoro.
- `1`: Timing/stopwatch.

Important focus fields:

- `id`, `type`, `taskId`, `note`, `status`.
- `startTime`, `endTime`, `duration`.
- `tasks`: related task briefs when returned.

For reports, aggregate focus by date, project/task, and duration when possible.
