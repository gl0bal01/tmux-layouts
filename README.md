# tmux-layouts

Own tmux configuration + curated `tmuxp` layouts for project, docker, pentest, malware analysis, OSINT, and CTF workflows (prefix `C-a`, intuitive splits, vi mode, sensible defaults) and pairs it with TPM-managed plugins (Catppuccin, resurrect, continuum, fzf, thumbs, vim-tmux-navigator) for a productive, modern terminal multiplexer setup.

Sister project to [zellij-layouts](https://github.com/gl0bal01/zellij-layouts) — same workflows, different multiplexer.

## What you get

- **Own `tmux.conf`** — no upstream dependency to track
- **Catppuccin Mocha** status bar via TPM
- **Plugin set** — `tmux-sensible`, `tmux-yank`, `tmux-pain-control`, `tmux-resurrect`, `tmux-continuum`, `tmux-fzf`, `tmux-thumbs`, `vim-tmux-navigator`, `catppuccin/tmux`
- **Mouse copy fix** — no more cross-pane content capture when dragging across borders
- **Clipboard auto-detect** — Wayland (`wl-copy`), X11 (`xclip`/`xsel`), macOS (`pbcopy`)
- **7 tmuxp layouts** — `claude-projects` (generated multi-project), `project`, `docker`, `pentest`, `malware-analysis`, `osint`, `ctf`
- **Shell helpers** — `tp`, `tdk`, `tpt`, `tma`, `tos`, `tctf` + `*-new` variants for ad-hoc engagements

## Prereqs

- `tmux >= 3.2` (3.3+ recommended for full Catppuccin features)
- `tmuxp >= 1.x` — `pipx install tmuxp` or `apt install tmuxp` / `brew install tmuxp`
- `git`, `python3`
- Linux clipboard backend:
  - Wayland session: `wl-clipboard` (provides `wl-copy`)
  - X11 session: `xclip` (preferred) or `xsel`
- Optional for the `🏠 cockpit` window: `btop`, `bunx` + `ccusage`
- A Nerd Font or Noto Color Emoji is recommended (window names use emoji)

## Install

```bash
git clone https://github.com/gl0bal01/tmux-layouts ~/tmux-layouts
cd ~/tmux-layouts
make setup     # creates ~/projects, ~/docker, ~/ops/{pentest,malware,osint,ctf}
make install   # lint + symlink tmux.conf + copy layouts + bootstrap TPM
echo 'source ~/tmux-layouts/tmux-layouts.zsh' >> ~/.zshrc
exec zsh       # or open a new shell
```

If a `~/.tmux.conf` already exists, it's moved to `~/.tmux.conf.bak.<timestamp>` before the symlink is created — nothing is silently overwritten.

If a tmux server is already running, run `tmux source-file ~/.tmux.conf` or `tmux kill-server` and re-launch to pick up the new config. TPM plugin install is best-effort during `make install`; if it fails, open tmux and press `prefix + I` to retry.

## Layouts

| Layout | Launch | Default cwd | Session name |
|---|---|---|---|
| `claude-projects` | `tp` | `~/projects` | `claude` |
| `project` | `tp-new <name>` | `~/projects/<name>` | `<name>` |
| `docker` | `tdk` / `tdk-new <stack>` | `~/docker[/<stack>]` | `docker` / `dk-<stack>` |
| `pentest` | `tpt` / `tpt-new <engagement>` | `~/ops/pentest[/<eng>]` | `pentest` / `pt-<eng>` |
| `malware-analysis` | `tma` / `tma-new <sample>` | `~/ops/malware[/<sample>]` | `malware` / `ma-<sample>` |
| `osint` | `tos` / `tos-new <target>` | `~/ops/osint[/<target>]` | `osint` / `os-<target>` |
| `ctf` | `tctf` / `tctf-new <ctf>` | `~/ops/ctf[/<ctf>]` | `ctf` / `ctf-<ctf>` |

Run `th` (or `thelp`) for the full alias reference.

## Aliases

```
Layout launchers
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
```

## Editing the multi-project layout

`layouts/claude-projects.yaml` is a build artifact — edit `generate-layout.sh`, not the YAML.

```bash
# generate-layout.sh
projects=(
  "frontend:🌐::logs/dev.log"
  "backend-api:🔌:api:logs/app.log"
  "cli-tool:🛠️::"
  # "my-project:🚀::logs/dev.log"
)
```

Format: `"dirname:emoji:label:logfile"`. `label` defaults to `dirname`. Leave `logfile` empty for a plain shell pane instead of a `tail -f`. After editing, run `make install`.

To keep your personal projects out of the repo, copy `generate-layout.sh` to `generate-layout.local.sh` and edit there — the Makefile prefers `*.local.sh` and `.gitignore` excludes it.

## tmuxp basics

- `tmuxp load -y <name>` — load a layout from `~/.config/tmuxp/`. `-y` answers "yes" to the "session exists, attach?" prompt.
- `tmuxp load -y <name> -s <other>` — override session name.
- `tmuxp load -y <name> --start-directory <path>` — override base cwd (used by `*-new` helpers).
- Inside tmux: tmuxp creates the session detached and switches client to it. Outside tmux: creates and attaches.

## Copy / paste & clipboard

This config fixes the common "drag across pane border captures content from neighboring panes" bug via `MouseDragEnd1Pane` → `copy-pipe-no-clear`. Two equally-good ways to copy:

1. **Mouse drag** — left-click and drag inside a single pane. Released selection is auto-copied to system clipboard via `tmux-yank`. **Do not hold Shift while dragging** — Shift bypasses tmux to terminal-native selection, which captures the whole grid (including other panes). This is a terminal behavior, not a tmux bug.
2. **Keyboard hints (recommended)** — `prefix Space` activates `tmux-thumbs`. URLs, paths, hashes, and IPs are highlighted with hint keys. Press the hint key to copy. No mouse needed.

Vi-mode copy: `prefix Enter` enters copy-mode, `v` to begin selection, `y` to yank.

The clipboard backend is auto-detected at tmux startup — Wayland's `wl-copy` is preferred when `$WAYLAND_DISPLAY` is set; otherwise `xclip` → `xsel` → `pbcopy` (in that order).

## Customizing

Copy `tmux.conf.local.example` to `~/.tmux.conf.local` and edit. The main `tmux.conf` sources it before plugin init, so it can override `@-options` like Catppuccin flavour, status bar position, or add custom binds.

```bash
cp tmux.conf.local.example ~/.tmux.conf.local
# edit ~/.tmux.conf.local
tmux source-file ~/.tmux.conf
```

## Troubleshooting

- **Plugins missing** — open tmux, press `prefix + I` (capital i) to install. Or rerun `make tpm`.
- **Reload config** — `prefix + r` or `tmux source-file ~/.tmux.conf`.
- **Status bar looks broken** — install a Nerd Font or Noto Color Emoji; some terminals also need `set -g default-terminal "tmux-256color"` matching their `$TERM`.
- **`tmuxp: command not found`** — `pipx install tmuxp` (recommended on PEP 668 distros) or `apt install tmuxp`.
- **`tmuxp load --start-directory` not recognized** — upgrade to tmuxp 1.x (`pipx upgrade tmuxp`).
- **Copy still picks up other panes** — make sure you're not holding Shift; if dragging without Shift still leaks, check that `tmux-yank` is loaded (`prefix + I` to install plugins).
- **Resurrect / continuum doesn't restore** — first run records state, subsequent tmux starts restore. Manual: `prefix + Ctrl-s` save, `prefix + Ctrl-r` restore.
- **Clipboard backend stuck on xclip under Wayland** — `WAYLAND_DISPLAY` is read by tmux at server start. If tmux is launched before the Wayland session exports the variable (some systemd user services, SSH-forwarded sessions, certain login managers), it falls back to `xclip`. Verify with `tmux show -gv @override_copy_command`; force re-detection with `tmux kill-server` and relaunch from a Wayland-aware shell.

## Uninstall

```bash
make uninstall   # removes installed layouts and ~/.tmux.conf symlink (keeps backups + TPM)
make clean       # also removes generated layouts/claude-projects.yaml
# Optional: rm -rf ~/.tmux/plugins
```

## License

MIT — see [LICENSE](LICENSE).
