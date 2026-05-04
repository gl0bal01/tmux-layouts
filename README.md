# tmux Layouts

![tmux](https://img.shields.io/badge/tmux-3.2+-green)
![tmuxp](https://img.shields.io/badge/tmuxp-1.x-blue)
![License](https://img.shields.io/badge/license-MIT-green)

> Own `tmux.conf` + curated `tmuxp` layouts for Claude Code projects, Docker, pentesting, malware analysis, OSINT, and CTF competitions — launch a full workspace with one command.

[tmux](https://github.com/tmux/tmux) is a terminal multiplexer with persistent sessions, splits, and copy-mode. [tmuxp](https://github.com/tmux-python/tmuxp) lets you define sessions in YAML and launch them with one command. This repo bundles a tuned `tmux.conf` (Catppuccin theme, sensible defaults, mouse-copy fix) with ready-to-use workspace layouts.

Sister project to [zellij-layouts](https://github.com/gl0bal01/zellij-layouts) — same workflows, different multiplexer.

## Quick start

```bash
git clone https://github.com/gl0bal01/tmux-layouts ~/tmux-layouts
cd ~/tmux-layouts
make setup      # one-time: ~/projects, ~/docker, ~/ops/{pentest,malware,osint,ctf}
make install    # lint + symlink tmux.conf + copy layouts + bootstrap TPM
echo 'source ~/tmux-layouts/tmux-layouts.zsh' >> ~/.zshrc
exec zsh
```

Then launch any layout (works from a bare terminal **or** inside an existing tmux session — tmuxp creates the session and switches the client to it):

```bash
tp                          # multi-project workspace
tctf-new htb-apocalypse     # ad-hoc CTF engagement: ~/ops/ctf/htb-apocalypse, session "ctf-htb-apocalypse"
```

If `~/.tmux.conf` already exists, `make install` moves it to `~/.tmux.conf.bak.<timestamp>` before symlinking — nothing is silently overwritten.

If a tmux server is already running, run `tmux source-file ~/.tmux.conf` (or `tmux kill-server` and relaunch) to pick up the new config. TPM plugin install is best-effort during `make install`; if it fails, open tmux and press `prefix + I` to retry.

---

## What is a layout?

A tmuxp layout is a `.yaml` file that describes:
- **Windows** — named workspaces you switch between (`prefix n` / `prefix p` / `prefix <number>`)
- **Panes** — terminal splits within a window
- **Commands** — auto-run commands per pane (`watch git status`, `tail -f log`, etc.)
- **Pane titles** — short label shown on pane border + dim cyan banner inside the pane as a reminder

Layouts live in `~/.config/tmuxp/`. tmuxp finds them by name:

```bash
tmuxp load -y <name>        # loads ~/.config/tmuxp/<name>.yaml
```

> Official docs: [tmuxp.git-pull.com](https://tmuxp.git-pull.com)

---

## Prereqs

- `tmux >= 3.2` (3.3+ recommended for full Catppuccin features)
- `tmuxp >= 1.x` — `pipx install tmuxp` or `apt install tmuxp` / `brew install tmuxp`
- `git`, `python3`
- Linux clipboard backend:
  - Wayland session: `wl-clipboard` (provides `wl-copy`)
  - X11 session: `xclip` (preferred) or `xsel`
- Optional for the `🏠 cockpit` window: `btop`, `bunx` + `ccusage`
- A Nerd Font or Noto Color Emoji is recommended (window names use emoji)

---

## What you get

- **Own `tmux.conf`** — no upstream dependency to track, prefix `C-a`
- **Catppuccin Mocha** status bar via TPM
- **Plugin set** — `tmux-sensible`, `tmux-yank`, `tmux-pain-control`, `tmux-resurrect`, `tmux-continuum`, `tmux-fzf`, `tmux-thumbs`, `vim-tmux-navigator`, `catppuccin/tmux`
- **Pane border titles** — every pane in every layout sets a short title shown on the top border
- **Reminder banners** — first line in each pane shows a dim cyan reminder of available tools / commands for that role
- **Mouse copy fix** — no more cross-pane content capture when dragging across borders
- **Clipboard auto-detect** — Wayland (`wl-copy`), X11 (`xclip`/`xsel`), macOS (`pbcopy`)
- **7 tmuxp layouts** — `claude-projects` (generated multi-project), `project`, `docker`, `pentest`, `malware-analysis`, `osint`, `ctf`
- **Shell helpers** — `tp`, `tdk`, `tpt`, `tma`, `tos`, `tctf` + `*-new` variants for ad-hoc engagements

---

## Available layouts

### `claude-projects` — Multi-project workspace

```bash
tp                          # launch (session: "claude")
```

Multiple project windows generated from `generate-layout.sh`, each with:
- **70% left** — main `claude` shell (focused)
- **30% right** — live `git status` (top) + log tail or shell (bottom)

Plus fixed windows: `🏠 cockpit` (btop + ccusage) and `🧪 scratch`.

### `project` — Single project

```bash
tp-new my-app               # creates ~/projects/my-app + session "my-app"
tmuxp load -y project --start-directory ~/projects/anywhere   # ad-hoc cwd
```

Single window with the same 70/30 pane pattern (claude / git / shell).

### `docker` — Docker / Compose

```bash
tdk                         # launch (session: "docker", cwd: ~/docker)
tdk-new my-stack            # creates ~/docker/my-stack, session "dk-my-stack"
```

| Window | Pane titles |
|---|---|
| `🐳 cockpit` | `lazydocker` (auto-detect, falls back to `watch docker ps`) · `compose` · `exec` |
| `📜 logs` | `logs` · `compose logs` |
| `🧪 scratch` | `scratch` · `scratch` |

### `pentest` — Penetration testing

```bash
tpt                         # launch (session: "pentest", cwd: ~/ops/pentest)
tpt-new acme-corp           # creates ~/ops/pentest/acme-corp, session "pt-acme-corp"
```

| Window | Pane titles |
|---|---|
| `🎯 cockpit` | `notes` · `shell` · `loot` |
| `🔎 recon` | `scan` · `subdomains` · `fuzz` · `probe` |
| `💥 exploit` | `msf` · `payload` · `listener` · `target` |
| `🔓 post` | `privesc` · `lateral` · `persist` · `exfil` |
| `📝 report` | `report` · `evidence` |

### `malware-analysis` — Malware analysis

```bash
tma                         # launch (session: "malware", cwd: ~/ops/malware)
tma-new emotet              # creates ~/ops/malware/emotet, session "ma-emotet"
```

| Window | Pane titles |
|---|---|
| `🧬 cockpit` | `notes` · `shell` · `samples` (live) · `detect` |
| `🔬 static` | `strings` · `PE` · `disasm` · `yara` |
| `🧪 dynamic` | `sandbox` · `procmon` · `netcap` · `behavior` |
| `🌐 network` | `C2` · `pcap` |
| `📝 report` | `IoC` · `report` |

### `osint` — OSINT investigation

```bash
tos                         # launch (session: "osint", cwd: ~/ops/osint)
tos-new target-co           # creates ~/ops/osint/target-co, session "os-target-co"
```

| Window | Pane titles |
|---|---|
| `🕵️ cockpit` | `dossier` · `shell` · `evidence` |
| `👤 identity` | `username` · `email` · `phone` · `face` |
| `🌐 web` | `domain` · `wayback` · `search` · `fetch` |
| `📡 social` | `twitter` · `instagram` · `linkedin/gh` · `telegram` |
| `🗺️ geo` | `geoint` · `exif` |
| `📝 report` | `report` · `evidence` |

### `ctf` — CTF competition

```bash
tctf                        # launch (session: "ctf", cwd: ~/ops/ctf)
tctf-new htb-apocalypse     # creates ~/ops/ctf/htb-apocalypse, session "ctf-htb-apocalypse"
```

| Window | Pane titles |
|---|---|
| `🏁 cockpit` | `tracker` · `flags` · `submit` |
| `🌐 web` | `requests` · `source` · `proxy` · `exploit` |
| `💥 pwn` | `gdb` · `disasm` · `pwntools` · `gadgets` |
| `🔐 crypto` | `repl` · `solve.py` · `tools` · `scratch` |
| `🔎 forensics` | `analyze` · `hex` · `stego` · `pcap` |
| `🧰 misc` | `solve` · `recon` · `decode` · `scratch` |

> Each pane prints a dim cyan reminder banner with the full tool list (e.g. `▎ stego — steghide · zsteg · stegsolve · openstego`).

---

## How sessions work

tmux sessions persist after detach. Multiple sessions can run in parallel, switch between them with `prefix s` (interactive picker).

```bash
tmuxp load -y pentest -s acme-night       # named session
tmuxp load -y pentest -s acme-night -d    # detached (don't attach)
```

If a session with that name already exists, tmuxp prompts to attach. `-y` answers "yes" automatically. Inside tmux, tmuxp creates the session detached and switches the client. Outside tmux, it creates and attaches.

| Action | Command / Keybind |
|---|---|
| List sessions | `tls` (= `tmux list-sessions`) |
| Attach to session | `ta <name>` |
| Detach (keeps running) | `prefix d` |
| Switch session (inside tmux) | `prefix s` |
| Kill one session | `tks <name>` |
| Kill all sessions | `tka` (= `tmux kill-server`) |

---

## Navigating inside tmux

Prefix is **`C-a`** (Ctrl+a). Press the prefix, then the action key.

### Windows (tabs)

| Action | Keybind |
|---|---|
| Next / previous window | `prefix n` / `prefix p` |
| Go to window by number | `prefix 1`–`9` |
| New window (in current cwd) | `prefix c` |
| Rename window | `prefix ,` |
| Window picker | `prefix w` |

### Panes

| Action | Keybind |
|---|---|
| Split horizontal (same cwd) | `prefix _` |
| Split vertical (same cwd) | `prefix -` |
| Move focus | `prefix h/j/k/l` (or `vim-tmux-navigator` `C-h/j/k/l`) |
| Toggle zoom (full-screen pane) | `prefix z` |
| Cycle pane layouts | `prefix Space` would conflict — use `prefix M-1`..`M-5` for built-in layouts |
| Kill pane | `prefix x` |

### Copy / scroll mode

| Action | Keybind |
|---|---|
| Enter copy-mode | `prefix Enter` |
| Begin selection | `v` (vi-mode) |
| Line selection | `V` |
| Rectangle | `C-v` |
| Yank | `y` |
| Search | `/` (forward) / `?` (backward) |
| **Hint-copy (recommended)** | `prefix Space` (`tmux-thumbs` highlights URLs/paths/hashes/IPs) |

### Reload + plugins

| Action | Keybind |
|---|---|
| Reload `~/.tmux.conf` | `prefix r` |
| Install plugins (TPM) | `prefix I` |
| Update plugins | `prefix U` |
| Save session (resurrect) | `prefix C-s` |
| Restore session | `prefix C-r` |

> Full default keybinding reference: `man tmux` or [github.com/tmux/tmux/wiki](https://github.com/tmux/tmux/wiki).

---

## Shell setup

Source the repo helper from `~/.zshrc` or `~/.bashrc`:

```bash
source ~/tmux-layouts/tmux-layouts.zsh
```

That gives you the aliases below plus `th` / `thelp`, a short reference printed in the terminal.

### Aliases

```bash
# tmux
alias t='tmux'

# Layout launchers — work both inside and outside tmux
alias tp='tmuxp load -y claude-projects'         # multi-project workspace
alias tdk='tmuxp load -y docker'                 # docker workflow
alias tpt='tmuxp load -y pentest'                # pentest workflow
alias tma='tmuxp load -y malware-analysis'       # malware analysis
alias tos='tmuxp load -y osint'                  # osint investigation
alias tctf='tmuxp load -y ctf'                   # ctf competition

# Session management
alias tls='tmux list-sessions'
alias ta='tmux attach -t'
alias tks='tmux kill-session -t'
alias tka='tmux kill-server'
```

Help:

```bash
th       # show layout command reference
thelp    # same as th
```

### Per-engagement functions

```bash
# tp-new my-app    → ~/projects/my-app,    session "my-app"
# tdk-new stack    → ~/docker/stack,        session "dk-stack"
# tpt-new acme     → ~/ops/pentest/acme,   session "pt-acme"
# tma-new emotet   → ~/ops/malware/emotet, session "ma-emotet"
# tos-new corp     → ~/ops/osint/corp,     session "os-corp"
# tctf-new htb     → ~/ops/ctf/htb,        session "ctf-htb"
```

All of these `mkdir -p` the target directory and call `tmuxp load -y <layout> -s <prefix><name> --start-directory <path>`. Implementation lives in `tmux-layouts.zsh`.

---

## Customising `claude-projects`

`layouts/claude-projects.yaml` is a build artifact — edit `generate-layout.sh`, not the YAML.

```bash
# generate-layout.sh
projects=(
  "frontend:🌐::logs/dev.log"
  "backend-api:🔌:api:logs/app.log"
  "cli-tool:🛠️::"                # no log → plain shell pane
  # "my-project:🚀::logs/dev.log"
)
```

Format: `"dirname:emoji:label:logfile"`
- `dirname` — subdirectory under `~/projects/`
- `emoji` — window icon
- `label` — window display name (defaults to `dirname` if empty)
- `logfile` — path to tail relative to project dir (omit for plain shell pane)

Then run `make install`.

To keep your personal projects out of the repo, copy `generate-layout.sh` to `generate-layout.local.sh` and edit there — the Makefile prefers `*.local.sh` and `.gitignore` excludes it.

---

## Customising tmux

Copy `tmux.conf.local.example` to `~/.tmux.conf.local` and edit. The main `tmux.conf` sources it before plugin init, so you can override `@-options` (Catppuccin flavour, status bar position, custom binds).

```bash
cp tmux.conf.local.example ~/.tmux.conf.local
# edit ~/.tmux.conf.local
tmux source-file ~/.tmux.conf
```

---

## Make targets

```
make            # regenerate layouts/claude-projects.yaml
make install    # lint + regenerate + symlink tmux.conf + copy layouts + bootstrap TPM
make uninstall  # remove installed layouts and ~/.tmux.conf symlink (keeps backups + TPM)
make clean      # remove generated + installed files
make setup      # create ~/projects, ~/docker, ~/ops/{pentest,malware,osint,ctf}
make lint       # validate YAML syntax + tmux.conf parses
make list       # show installed layouts
make tpm        # bootstrap TPM and install plugins (idempotent)
make help       # show all targets
```

---

## Copy / paste & clipboard

This config fixes the common "drag across pane border captures content from neighboring panes" bug via `MouseDragEnd1Pane` → `copy-pipe-no-clear`. Two equally-good ways to copy:

1. **Mouse drag** — left-click and drag inside a single pane. Released selection is auto-copied to system clipboard via `tmux-yank`. **Do not hold Shift while dragging** — Shift bypasses tmux to terminal-native selection, which captures the whole grid (including other panes). This is a terminal behavior, not a tmux bug.
2. **Keyboard hints (recommended)** — `prefix Space` activates `tmux-thumbs`. URLs, paths, hashes, and IPs are highlighted with hint keys. Press the hint key to copy. No mouse needed.

Vi-mode copy: `prefix Enter` enters copy-mode, `v` to begin selection, `y` to yank.

The clipboard backend is auto-detected at tmux startup — Wayland's `wl-copy` is preferred when `$WAYLAND_DISPLAY` is set; otherwise `xclip` → `xsel` → `pbcopy` (in that order).

---

## Tips

- **Pane border titles missing?** They need `prefix r` after install (or `tmux source-file ~/.tmux.conf`). Without the new conf, `pane-border-status` is off.
- **Banner wraps onto two lines.** Banner length > pane width. Resize the pane (`prefix M-1`..`M-5`, `prefix z` to zoom) or shorten the banner in the YAML.
- **Long-running TUI in a pane?** Banner is overwritten by the TUI (e.g. `btop`, `watch`, `tail -f`). Pane title still shown in the border.
- **Window names get clobbered by running commands?** This config sets `automatic-rename off` and `allow-rename off` so `window_name` from the YAML stays put.
- **Resurrect / continuum doesn't restore?** First run records state, subsequent tmux starts restore. Manual: `prefix C-s` save, `prefix C-r` restore.
- **`tmuxp: command not found`** — `pipx install tmuxp` (recommended on PEP 668 distros) or `apt install tmuxp`.
- **Status bar looks broken** — install a Nerd Font or Noto Color Emoji; some terminals also need `set -g default-terminal "tmux-256color"` matching their `$TERM`.
- **Clipboard backend stuck on xclip under Wayland** — `WAYLAND_DISPLAY` is read at server start. If tmux is launched before the Wayland session exports it, falls back to xclip. Verify with `tmux show -gv @override_copy_command`; force re-detection with `tmux kill-server` and relaunch from a Wayland-aware shell.

---

## Uninstall

```bash
make uninstall   # removes installed layouts and ~/.tmux.conf symlink (keeps backups + TPM)
make clean       # also removes generated layouts/claude-projects.yaml
# Optional: rm -rf ~/.tmux/plugins
```

---

## Resources

- [tmux GitHub](https://github.com/tmux/tmux) · [tmux wiki](https://github.com/tmux/tmux/wiki)
- [tmuxp docs](https://tmuxp.git-pull.com) · [tmuxp YAML reference](https://tmuxp.git-pull.com/configuration/index.html)
- [TPM — tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Catppuccin tmux theme](https://github.com/catppuccin/tmux)
- [tmux-thumbs (hint copy)](https://github.com/fcsonline/tmux-thumbs)

---

## License

MIT — see [LICENSE](LICENSE).
