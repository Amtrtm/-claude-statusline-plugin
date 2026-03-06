#!/usr/bin/env bash
# SessionStart hook: auto-configure statusLine in settings.json if not already set
# This ensures the plugin works out of the box after installation.

SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_PATH="${CLAUDE_PLUGIN_ROOT}/scripts/statusline-command.sh"

# Ensure the script is executable
chmod +x "$SCRIPT_PATH" 2>/dev/null

# Check if statusLine is already configured
if [ -f "$SETTINGS_FILE" ]; then
  if grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
    exit 0
  fi
fi

# If no settings file exists, create minimal one
if [ ! -f "$SETTINGS_FILE" ]; then
  mkdir -p "$(dirname "$SETTINGS_FILE")"
  echo '{}' > "$SETTINGS_FILE"
fi

# Inject statusLine config using sed (no jq dependency)
# Insert before the last closing brace
if grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
  exit 0
fi

# Use a temp file for safe writing
tmp_file=$(mktemp)
# Add statusLine before the final }
sed '$ s/}$/,"statusLine":{"type":"command","command":"bash '"$(echo "$SCRIPT_PATH" | sed 's/\\/\\\\/g; s/"/\\"/g')"'"}}/' "$SETTINGS_FILE" > "$tmp_file"
mv "$tmp_file" "$SETTINGS_FILE"
