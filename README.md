# claude-statusline-plugin

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform: Linux | macOS | Windows](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue.svg)](#)
[![Shell: Bash](https://img.shields.io/badge/shell-bash-orange.svg)](#)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-plugin-blueviolet.svg)](#)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-0-brightgreen.svg)](#)

A PS1-style status line for Claude Code with the **only compaction counter** available. See at a glance how full your context window is, how many times it's been compacted, and what you're spending — all in a familiar terminal prompt layout.

## Screenshot

```
amtrt@myhost Linux ~/projects/my-app (main)
 ███░░░░░░░ 38k/200k 19% [0] $0.42
```

## Why This Plugin?

Other statusline solutions show context usage — this one also **tracks compactions**. When your context window gets compressed, you'll see `[1]`, `[2]`, etc. increment in real time. This helps you understand how aggressively your session is being compacted and when it might be time to start fresh.

## Features

- **Compaction counter** — `[N]` tracks how many times your conversation was compacted (unique to this plugin)
- **Context window bar** — 10-character visual bar showing how full your context is
- **Color-coded thresholds** — white (0-50%), yellow (51-75%), red (76%+)
- **Git branch** — current branch or short SHA
- **Session cost** — running USD cost
- **Cross-platform** — works on Linux, macOS, and Windows (Git Bash / MSYS2)
- **Zero dependencies** — pure bash, no jq or external tools required
- **Auto-setup** — works out of the box via SessionStart hook

## Installation

### From Claude Plugins Marketplace (once approved)

```
/plugin install claude-statusline@claude-plugins-official
```

Or browse via `/plugin > Discover`.

### From GitHub (available now)

```
/plugin marketplace add Amtrtm/-claude-statusline-plugin
```

### Manual (local)

1. Clone this repo:
   ```bash
   git clone https://github.com/Amtrtm/-claude-statusline-plugin.git ~/.claude/plugins/local/claude-statusline
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
