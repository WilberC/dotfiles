# Qwen Configuration

Qwen Code uses per-agent configuration stored in `~/.qwen/`. This document explains the structure and provides examples.

## Configuration Location

- **Settings**: `~/.qwen/settings.json` — main configuration file for Qwen
- **Example**: `ai-skills/.qwen/example.settings.json` — example settings with Qwen model configuration

## Example Settings

The example config at `ai-skills/.qwen/example.settings.json` shows how to configure:

- **Model provider** — OpenAI-compatible API (e.g., LM Studio)
- **Model selection** — Specify the model name (e.g., `qwen/qwen3.5-9b`)
- **Environment variables** — API keys and tokens
- **IDE integration** — Enable/disable IDE features

### Example Configuration

```json
{
    "env": {
        "LMSTUDIO_API_KEY": "sk-lm-THIS:IS-YOUR-TOKEN"
    },
    "modelProviders": {
        "openai": [
            {
                "id": "qwen/qwen3.5-9b",
                "name": "qwen/qwen3.5-9b (LM Studio)",
                "envKey": "LMSTUDIO_API_KEY",
                "baseUrl": "http://localhost:1234/v1",
                "generationConfig": {
                    "timeout": 60000,
                    "samplingParams": {
                        "temperature": 0.5
                    }
                }
            }
        ]
    },
    "$version": 3,
    "ide": {
        "enabled": true,
        "hasSeenNudge": true
    },
    "security": {
        "auth": {
            "selectedType": "openai"
        }
    },
    "model": {
        "name": "qwen/qwen3.5-9b"
    }
}
```

## YOLO Mode (`-y` Flag)

Qwen supports a `--yolo` flag that runs in permissive mode without prompts for permission requests. To make this the default:

### Option 1: Command-line alias

Add to your shell aliases (e.g., `~/.config/zsh/config.d/98-aliases.zsh`):

```zsh
alias qwen='qwen --yolo'
```

Now running `qwen` automatically uses YOLO mode. Use `qwen --help` to see all flags if needed.

### Option 2: Settings-based default

You can also configure the default behavior in your settings file:

```json
{
    "env": { ... },
    "modelProviders": { ... },
    "$version": 3,
    "ide": {
        "enabled": true,
        "hasSeenNudge": true
    },
    "security": {
        "auth": {
            "selectedType": "openai"
        }
    },
    "model": {
        "name": "qwen/qwen3.5-9b"
    },
    "yoloMode": true  // Set to true for default YOLO mode
}
```

Then use `qwen` without flags, or override with `qwen --no-yolo` if needed.

## Related Docs

- [Agent symlink isolation](agent-symlinks.md) — Understanding how Qwen shares skills with other agents
- [Tools and commands](tools-and-commands.md) — Global AI agent skills workflow
