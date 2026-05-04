# tmux-layouts.zsh
# tmux layout helpers for this repo. Source from ~/.zshrc after install:
#   source ~/tmux-layouts/tmux-layouts.zsh

alias t='tmux'

# Layout launchers (work both inside and outside tmux — tmuxp creates and switches client).
alias tp='tmuxp load -y claude-projects'
alias tdk='tmuxp load -y docker'
alias tpt='tmuxp load -y pentest'
alias tma='tmuxp load -y malware-analysis'
alias tos='tmuxp load -y osint'
alias tctf='tmuxp load -y ctf'

# Session helpers.
alias tls='tmux list-sessions'
alias ta='tmux attach -t'
alias tks='tmux kill-session -t'
alias tka='tmux kill-server'

_tmux_layout_new() {
  local usage="$1" layout="$2" prefix="$3" base="$4" name="$5"
  if [[ -z "$name" ]]; then
    echo "Usage: $usage"
    return 1
  fi
  mkdir -p "$base/$name"
  # tmuxp 1.x: --start-directory rebases the session, -s overrides session name.
  tmuxp load -y "$layout" -s "${prefix}${name}" --start-directory "$base/$name"
}

tp-new()   { _tmux_layout_new "tp-new <project-name>"     project          ""     "$HOME/projects"     "$1"; }
tdk-new()  { _tmux_layout_new "tdk-new <stack-name>"      docker           "dk-"  "$HOME/docker"       "$1"; }
tpt-new()  { _tmux_layout_new "tpt-new <engagement>"      pentest          "pt-"  "$HOME/ops/pentest"  "$1"; }
tma-new()  { _tmux_layout_new "tma-new <sample-name>"     malware-analysis "ma-"  "$HOME/ops/malware"  "$1"; }
tos-new()  { _tmux_layout_new "tos-new <target-name>"     osint            "os-"  "$HOME/ops/osint"    "$1"; }
tctf-new() { _tmux_layout_new "tctf-new <ctf-name>"       ctf              "ctf-" "$HOME/ops/ctf"      "$1"; }

th() {
  cat <<'EOF'
tmux layouts
  tp              claude-projects workspace
  tdk             docker workspace
  tpt             pentest workspace
  tma             malware-analysis workspace
  tos             osint workspace
  tctf            ctf workspace

Create named workspaces
  tp-new <name>      ~/projects/<name>, session <name>
  tdk-new <name>     ~/docker/<name>, session dk-<name>
  tpt-new <name>     ~/ops/pentest/<name>, session pt-<name>
  tma-new <name>     ~/ops/malware/<name>, session ma-<name>
  tos-new <name>     ~/ops/osint/<name>, session os-<name>
  tctf-new <name>    ~/ops/ctf/<name>, session ctf-<name>

Sessions
  tls             list sessions
  ta <name>       attach to session
  tks <name>      kill session
  tka             kill all sessions (kill-server)
EOF
}

alias thelp='th'
