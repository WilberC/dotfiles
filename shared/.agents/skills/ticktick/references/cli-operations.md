# CLI Operations

## General Rules

- Assume `ticktick` is installed and authenticated.
- Use `--json` for reads that feed decisions.
- Run `ticktick <command> --help` only when a command option is uncertain.
- Resolve project names to IDs with `ticktick project list --json`.
- Resolve task candidates from `project data`, `task filter`, `task completed`, or explicit IDs.
- Never invent IDs.

## Projects

```bash
ticktick project list --json
ticktick project get <projectId> --json
ticktick project data <projectId> --json
ticktick project create --name "<name>" --color "#F18181" --view-mode list --kind TASK --json
ticktick project update <projectId> --name "<name>" --color "#4AB8A9" --json
ticktick project delete <projectId>
```

Use `project data` when a report needs the incomplete tasks and kanban columns for one project.

## Project Groups And Columns

```bash
ticktick project group list --json
ticktick project group create --name "<name>" --json
ticktick project group update <groupId> --name "<name>" --json
ticktick project group delete <groupId>

ticktick project column list <projectId> --json
ticktick project column create <projectId> --name "<name>" --json
ticktick project column update <projectId> <columnId> --name "<name>" --json
```

Use columns for kanban-style projects. Confirm before reorganizing columns or groups.

## Tasks

```bash
ticktick task get <projectId> <taskId> --json
ticktick task create --title "<title>" --project <projectId> --json
ticktick task update <taskId> --id <taskId> --project <projectId> --title "<title>" --json
ticktick task complete <projectId> <taskId>
ticktick task delete <projectId> <taskId>
ticktick task move --from <sourceProjectId> --to <destProjectId> --task <taskId> --json
ticktick task completed --projects <projectId> --start-date "<from>" --end-date "<to>" --json
ticktick task filter --projects <projectId> --priority 3,5 --status 0 --json
```

Common create/update flags:

- `--content "<text>"`
- `--desc "<checklist description>"`
- `--start-date "<yyyy-MM-dd'T'HH:mm:ssZ>"`
- `--due-date "<yyyy-MM-dd'T'HH:mm:ssZ>"`
- `--time-zone "<IANA timezone>"`
- `--all-day`
- `--priority 0|1|3|5`
- `--tags tag1,tag2`
- `--reminders "<trigger1>,<trigger2>"`
- `--repeat "<RRULE or ERULE>"`
- `--items "<checklist items>"`
- `--parent-id <parentTaskId>` or `--parent-id null`
- `--estimated-duration <seconds>`
- `--estimated-pomo <count>`

## Comments

```bash
ticktick task comment list <projectId> <taskId> --json
ticktick task comment add <projectId> <taskId> --title "<comment>" --json
ticktick task comment delete <projectId> <taskId> <commentId>
```

Use comments for audit notes like "Moved during weekly review" only when useful; avoid clutter.

## Tags

```bash
ticktick tag list --json
ticktick tag create --name <name> --label <label> --json
```

Use tags for cross-project contexts such as `urgent`, `waiting`, `deep-work`, `errand`, or user-defined categories. Confirm before creating many tags.

## Habits

```bash
ticktick habit list --json
ticktick habit get <habitId> --json
ticktick habit create --name "<name>" --goal 8 --unit cups --repeat "RRULE:FREQ=DAILY;INTERVAL=1" --json
ticktick habit update <habitId> --name "<name>" --goal 10 --json
ticktick habit checkin <habitId> --stamp <YYYYMMDD> --value 1 --goal 8 --json
ticktick habit checkins --habits <habitId1>,<habitId2> --from <YYYYMMDD> --to <YYYYMMDD> --json
```

Use habits in personal status reports and routine planning.

## Focus

```bash
ticktick focus get <focusId> --type pomodoro --json
ticktick focus list --from "<from>" --to "<to>" --type 0 --json
ticktick focus list --from "<from>" --to "<to>" --type 1 --json
ticktick focus create --type pomodoro --task-id <taskId> --start-time "<from>" --end-time "<to>" --duration <seconds> --json
ticktick focus delete <focusId> --type timing
```

Type values: `0` or `pomodoro` for Pomodoro, `1` or `timing` for stopwatch/timing if supported by the CLI.

## Countdown

```bash
ticktick countdown list --json
```

Use countdowns as date-based context in planning and status reports.
