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
          - tmux select-pane -t "\$TMUX_PANE" -T $(yaml_q "logs — $logfile")
          - tail -f $(yaml_q "$logfile")
EOF
  else
    cat <<EOF
      - shell_command:
          - tmux select-pane -t "\$TMUX_PANE" -T 'shell'
          - printf '\\e[H\\e[2J\\e[2;36m▎ %s\\e[0m\\n\\n' 'shell'
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
cat <<'COCKPIT'
  - window_name: 🏠 cockpit
    focus: true
    layout: tiled
    panes:
      - focus: true
        shell_command:
          - tmux select-pane -t "$TMUX_PANE" -T 'btop'
          - btop
      - shell_command:
          - tmux select-pane -t "$TMUX_PANE" -T 'shell'
          - printf '\e[H\e[2J\e[2;36m▎ %s\e[0m\n\n' 'shell'
      - shell_command:
          - tmux select-pane -t "$TMUX_PANE" -T 'ccusage'
          - bunx ccusage daily --instances --compact
      - shell_command:
          - tmux select-pane -t "$TMUX_PANE" -T 'shell'
          - printf '\e[H\e[2J\e[2;36m▎ %s\e[0m\n\n' 'shell'
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
          - tmux select-pane -t "\$TMUX_PANE" -T 'claude'
          - printf '\\e[H\\e[2J\\e[2;36m▎ %s\\e[0m\\n\\n' $(yaml_q "claude — $label")
      - shell_command:
          - tmux select-pane -t "\$TMUX_PANE" -T 'git'
          - watch -n 5 -c 'git status -sb 2>/dev/null || echo "no git repo"'
$(emit_log_pane "$logfile")
EOF
done

# ── Scratch window ─────────────────────────────────────────────────
cat <<'FOOTER'
  - window_name: 🧪 scratch
    layout: even-horizontal
    panes:
      - shell_command:
          - tmux select-pane -t "$TMUX_PANE" -T 'scratch'
          - printf '\e[H\e[2J\e[2;36m▎ %s\e[0m\n\n' 'scratch'
      - shell_command:
          - tmux select-pane -t "$TMUX_PANE" -T 'scratch'
          - printf '\e[H\e[2J\e[2;36m▎ %s\e[0m\n\n' 'scratch'
FOOTER
