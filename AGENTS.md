# Repository instructions

## Custom tools

When adding or materially changing a custom tool—such as a Fish function,
script in `shared/.local/bin/`, or a program under `tools/`—update
[`docs/custom-tools.md`](docs/custom-tools.md) in the same change.

Every index entry must state, at minimum:

1. what the tool is mainly for; and
2. how to use it, including its primary command or invocation.

Keep the index focused on user-facing custom tools. Do not add ordinary
third-party commands or internal implementation helpers unless users invoke
them directly.
