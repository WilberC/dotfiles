# Agent platform machine integration

## Document contract

- **Purpose:** define what `dotfiles` may install or configure for the portable
  agent platform without taking ownership away from `dotfiles-skills` or
  overwriting mutable harness state.
- **Audience:** maintainers implementing Stow packages, wrappers, package setup,
  or per-environment configuration for Codex, Claude Code, and Pi.
- **Owner:** the `dotfiles` repository maintainer.
- **Update trigger:** revise this document when an owned machine path, package,
  setup command, merge rule, or platform integration changes.

## Ownership boundary

The portable platform belongs to `~/dotfiles-skills`. It owns capability
profiles, catalog metadata, resolution, materialization, model-policy
abstractions, adapters, and the optional registry/search surface.

This repository owns only machine-level integration:

- GNU Stow-managed, non-secret configuration that is safe to own completely;
- launchers or wrappers that invoke tools from `~/dotfiles-skills`;
- supported installation commands for external packages;
- environment-specific paths and package availability;
- merge-safe additions to mutable harness configuration.

## Current-state constraints

The first implementation must account for behavior already in use:

- `dotfiles-skills` links selected skills to Codex, Claude, and the generic
  Agents target.
- Shared global context is linked to Codex, Claude, and Pi.
- Codex's active `~/.codex/config.toml` is intentionally mutable and is not
  Stow-managed; this repository provides a template instead.
- Claude's active settings may contain plugins, hooks, permissions, status-line
  configuration, and other user-managed values.
- Pi's active settings may contain package entries and MCP configuration.
- Engram is already installed and must not be duplicated or reconfigured as a
  side effect of platform setup.
- `gentle-pi` is an independent manual tool and must not be installed, invoked,
  imported, or required by this platform.

## Planned integration areas

The following paths are candidates, not yet approved Stow ownership:

```text
shared/.config/agents/   # non-secret machine mappings or launcher defaults
shared/.config/mcp/      # shared MCP config only when ownership is safe
shared/.local/bin/       # user-facing wrappers, documented in custom-tools.md
scripts/                 # idempotent setup/merge helpers that are not stowed
```

Do not create or Stow complete `~/.codex`, `~/.claude`, or `~/.pi` settings
files merely to add one platform value. Prefer, in order:

1. a harness-supported command or package manager;
2. an owned fragment/import mechanism;
3. an idempotent narrow merge with preview, backup, and validation;
4. a documented manual step when no safe automated contract exists.

## Verified adapter boundaries

The installed harness CLIs were inspected on 2026-09-14 before implementing the
portable adapter previews:

| Harness | Safe preview inputs | Unsupported or deferred input |
| --- | --- | --- |
| Pi | model, thinking level, repeated skill paths, MCP config path | automatic model mapping without an explicit class mapping |
| Claude Code | model, effort, additional directory, MCP config, plugin directory | direct session skill-root discovery |
| Codex | model, model_reasoning_effort config override, additional directory, ephemeral/json mode | direct session skill-root discovery |

The adapter command remains preview-only. It never launches a harness or
rewrites active settings. The portable implementation reports degraded status
when a harness lacks a verified session skill-root contract.

## External Pi packages

External packages remain independently versioned dependencies:

- `pi-mcp-adapter` provides token-efficient, lazy MCP discovery for Pi;
- `pi-lens` provides Pi-native edit-time diagnostics and may expose related MCP
  capabilities to other clients;
- `pi-btw` provides an optional side-conversation workflow;
- Engram remains the existing persistent-memory integration.

The platform may describe these capabilities in profiles, but this repository
must install them only through Pi's supported package workflow and preserve
unrelated package entries. Package source code is never vendored here.

## Model mapping

Portable profiles should request model classes and effort, not machine-specific
credentials. `dotfiles` may supply non-secret mappings from classes to models
available in a particular harness or environment. Missing mappings must produce
an explicit diagnostic; setup must not silently replace the user's default
model or provider.

## Safety requirements

- Preview every settings merge and Stow operation before applying it.
- Preserve unrelated files, symlinks, hooks, plugins, permissions, packages,
  MCP servers, and model settings.
- Never commit API keys, tokens, generated session roots, mutable histories, or
  agent transcripts.
- Make setup and removal idempotent.
- Document every new user-facing wrapper in [`custom-tools.md`](custom-tools.md)
  in the same change.
- Keep platform activation opt-in until the corresponding adapter has automated
  tests and a verified rollback path.

## Rollout controls

Agent-platform activation remains opt-in. The current default behavior is the
existing global skill linking and shared-context workflow. Rollout state is
kept outside Stow-managed files and can be inspected or changed with:

    sync-skills rollout status
    sync-skills rollout enable --harness pi
    sync-skills rollout disable --harness pi

Only Pi is currently eligible for opt-in activation because its installed CLI
exposes direct session skill paths. Codex and Claude Code remain blocked until
a direct session skill-root contract is verified. Enabling or disabling rollout
does not rewrite active harness settings or global skill links.

Before any physical harness test, run the portable local gate:

    sync-skills verify

This exercises temporary resolution, materialization, adapter diagnostics,
evaluation, rollout reversibility, and cleanup without launching a harness.

## Planned delivery sequence

1. Wait for the portable profile and resolver contracts in
   `dotfiles-skills`.
2. Confirm each harness's supported startup and configuration boundaries.
3. Add only the minimum non-secret mapping or wrapper required for one adapter.
4. Validate merge behavior against existing user-managed settings.
5. Add external Pi packages individually through supported commands and verify
   that existing package entries remain intact.
6. Keep each integration disabled by default until the coordinated platform
   phase documents successful compatibility evidence.

The canonical phased work breakdown lives in
`~/dotfiles-skills/docs/implementation-plan/`. This document intentionally does
not duplicate task checklists or portable architecture details.
