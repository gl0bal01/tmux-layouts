#!/usr/bin/env bash
# generate-layout.sh
#
# Generates a tmuxp layout from a list of projects.
# Usage: ./generate-layout.sh > layouts/claude-projects.yaml
#
# Format: "dirname:emoji:label:logfile"
#   dirname  — subdirectory under BASE_DIR (also used as cwd)
#   emoji    — window icon
#   label    — display name in window (optional; defaults to dirname)
#   logfile  — path to tail, relative to project dir (optional; omit for plain shell)

projects=(
  "frontend:🌐::logs/dev.log"
  "backend-api:🔌:api:logs/app.log"
  "cli-tool:🛠️::"                         # no log — plain shell
  # Add your projects here:
  # "my-project:🚀::logs/dev.log"
)

BASE_DIR="$HOME/projects"

# "true" to show status bar, "false" to hide
SHOW_STATUSBAR="true"

# YAML escape — escape single quotes inside a single-quoted scalar
yaml_q() {
  local s="$1"
  printf "'%s'" "${s//\'/\'\'}"
}

emit_log_pane() {
  local logfile="$1"
  if [[ -n "$logfile" ]]; then
    cat <<EOF
      - shell_command:
          - tail -f $(yaml_q "$logfile")
EOF
  else
    cat <<EOF
      - shell_command: [clear]
EOF
  fi
}

cat <<HEADER
# layouts/claude-projects.yaml
# Auto-generated — edit generate-layout.sh, not this file.
#
# Launch: tmuxp load -y claude-projects
session_name: claude
start_directory: $(yaml_q "$BASE_DIR")
options:
  status: $([ "$SHOW_STATUSBAR" = "true" ] && echo "on" || echo "off")
windows:
HEADER

# ── Cockpit window ─────────────────────────────────────────────────
cat <<COCKPIT
  - window_name: 🏠 cockpit
    focus: true
    layout: tiled
    panes:
      - focus: true
        shell_command:
          - btop
      - shell_command:
          - clear
      - shell_command:
          - bunx ccusage daily --instances --compact
      - shell_command:
          - clear
COCKPIT

# ── Project windows ────────────────────────────────────────────────
for entry in "${projects[@]}"; do
  IFS=':' read -r dirname icon label logfile <<< "$entry"
  label="${label:-$dirname}"
  cat <<EOF
  - window_name: $icon $label
    start_directory: $(yaml_q "$BASE_DIR/$dirname")
    layout: main-vertical
    options:
      main-pane-width: "70%"
    panes:
      - focus: true
        shell_command:
          - clear
      - shell_command:
          - watch -n 5 -c 'git status -sb 2>/dev/null || echo "no git repo"'
$(emit_log_pane "$logfile")
EOF
done

# ── Scratch window ─────────────────────────────────────────────────
cat <<'FOOTER'
  - window_name: 🧪 scratch
    layout: even-horizontal
    panes:
      - shell_command: [clear]
      - shell_command: [clear]
FOOTER
