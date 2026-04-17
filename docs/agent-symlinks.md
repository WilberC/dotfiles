# Agent Symlink Isolation Problem

## Current Situation

All agents (`caveman`, `qwen`, `claude`) currently share the same `.agents/skills` symlink:

```bash
.agents/caveman → .agents/skills
.agents/qwen    → .agents/skills
.agents/claude  → .agents/skills
```

This means adding a skill to one agent's directory automatically adds it to all agents.

## Why This Is Problematic

**`caveman` has special requirements:**
- Uses a special Claude installation (via plugin)
- Needs separate configs for Qwen and Kilocode
- Should NOT share skills with other agents

**Current behavior:**
```bash
# Adding to caveman affects ALL agents
mkdir -p .agents/caveman/skills/my-skill
# → my-skill now appears in qwen AND claude too!
```

## Proposed Solutions

### Option 1: Union Mount (Linux-specific)

Create a union mount where `my-folder` contains both A and B:

```bash
# Install unionfs-tools
sudo apt install unionfs-tools

# Create union mount for shared skills
mkdir -p ~/.dotfiles/agents/shared-skills
mount -t unionfs unionfs \
  -o ro:.agents/skills-original,ro:.agents/work/shared,special:B /path/to/my-folder
```

**Pros:** Single view of combined content  
**Cons:** Linux-only, requires root/mount permissions

### Option 2: FUSE-based Union (Cross-platform)

```bash
# Works on Linux, macOS, Windows (WSL)
sudo apt install unionfs-fuse

mount -t unionfs unionfs \
  -o ro:A,/path/to/A:ro:B,/path/to/B /path/to/my-folder
```

**Pros:** Cross-platform  
**Cons:** Requires FUSE installation on each machine

### Option 3: Wrapper Script Approach

Create a script that acts as the entry point:

```bash
#!/bin/bash
# ~/.dotfiles/agents/shared-skills.sh

SHARED_SKILLS="$1"
case "$SHARED_SKILLS" in
  */caveman|*/c)   # caveman-specific
    exec cat ~/.dotfiles/agents/caveman/skills/*
    ;;
  */qwen|*/q)      # qwen-specific
    exec cat ~/.dotfiles/agents/qwen/skills/*
    ;;
  */claude|*/cl)   # claude-specific
    exec cat ~/.dotfiles/agents/claude/skills/*
    ;;
  *)                # default: read from shared
    exec cat ~/.dotfiles/agents/shared/skills/*
    ;;
esac
```

**Pros:** Portable, no special tools needed  
**Cons:** Requires script execution in shell

### Option 4: Separate Skill Directories (Recommended)

Structure agents to have isolated skill directories:

```bash
.agents/caveman/skills/   → ~/.dotfiles/agents/caveman/skills/
.agents/qwen/skills/      → ~/.dotfiles/agents/qwen/skills/
.agents/claude/skills/    → ~/.dotfiles/agents/claude/skills/
```

Then use a shared directory for truly common skills:

```bash
# Shared skills (optional)
.agents/shared/skills/     → ~/.dotfiles/agents/shared/skills/
```

**Pros:** Clean isolation, no special tools  
**Cons:** Slightly more verbose paths

## Implementation Plan

1. **Short-term:** Use Option 4 (separate directories) - simplest and most portable
2. **Long-term:** Consider union mounts if you need a single unified view

## Files to Update

- `README.md` → Add link to this document under "Possible Improvements"
- `install.sh` → Create new step `06-agent-isolation.sh` for implementing chosen solution
- `.gitignore` → Add patterns for agent-specific skill directories
