# claude-statusline-plugin

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform: Linux | macOS | Windows](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](#)
[![Shell: Bash](https://img.shields.io/badge/shell-bash-orange.svg)](#)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-plugin-blueviolet.svg)](#)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-0-brightgreen.svg)](#)

A PS1-style status line for Claude Code that shows your context window usage as a colored bar, git branch, compaction count, and session cost.

## Screenshot

```
amtrt@myhost Linux ~/projects/my-app (main)
 ███░░░░░░░ 38k/200k 19% [0] $0.42
```

## Features

- **Context window bar** — 10-character visual bar showing how full your context is
- **Color-coded thresholds** — white (0-50%), yellow (51-75%), red (76%+)
- **Compaction counter** — `[N]` shows how many times the conversation was compacted
- **Git branch** — current branch or short SHA
- **Session cost** — running USD cost
- **Cross-platform** — works on Linux, macOS, and Windows (Git Bash / MSYS2)
- **Zero dependencies** — pure bash, no jq or external tools required

## Installation

### From Claude Plugins Marketplace

```
/install-plugin claude-statusline
```

### Manual (local)

1. Clone this repo:
   ```bash
   git clone https://github.com/amtrt/claude-statusline-plugin.git ~/.claude/plugins/local/claude-statusline
   ```

2. Enable in `~/.claude/settings.json`:
   ```json
   {
     "enabledPlugins": {
       "claude-statusline@local": true
     }
   }
   ```

3. The plugin auto-configures the statusLine on first session start. Or add manually:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/plugins/local/claude-statusline/scripts/statusline-command.sh"
     }
   }
   ```

## Layout

```
Line 1: user@host  Platform  /path/to/cwd (git-branch)
Line 2:  ███░░░░░░░ 38k/200k 19% [0] $0.42
```

| Element | Source |
|---------|--------|
| `user@host` | `whoami` + `hostname` |
| Platform | `$MSYSTEM` on Windows, `uname -s` on Linux/macOS |
| cwd | From Claude Code JSON input |
| git branch | `git symbolic-ref` / `rev-parse` |
| Context bar | `used_percentage` from JSON |
| `[N]` | Compaction count (tracked via temp state file) |
| `$0.42` | `total_cost_usd` from JSON |

## Customization

Use the built-in **statusline-setup** agent to customize:

> "Change my statusline bar colors"
> "Make the bar 20 characters wide"
> "Remove the cost from my statusline"

Or edit `scripts/statusline-command.sh` directly.

## How Compaction Tracking Works

Claude Code's statusline JSON doesn't include a compaction count, so the plugin tracks it by storing the previous `used_percentage` in a temp file (`/tmp/claude-statusline-{session_id}`). When usage drops by 15%+ between readings, it counts as a compaction.

## License

MIT
