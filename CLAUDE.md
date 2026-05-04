# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A tmux configuration + layouts repo containing:
- `tmux.conf` — own tmux configuration (prefix C-a, intuitive `-`/`_` splits, vi mode, sensible defaults)
- `tmux.conf.local.example` — personal-overrides template; copy to `~/.tmux.conf.local`
- `generate-layout.sh` — generates `layouts/claude-projects.yaml` from a projects list
- `tmux-layouts.zsh` — shell aliases/functions and `th` help for launching layouts
- `layouts/project.yaml` — single-project layout (static)
- `layouts/docker.yaml` — Docker/Compose workflow layout (static)
- `layouts/pentest.yaml`, `layouts/malware-analysis.yaml`, `layouts/osint.yaml`, `layouts/ctf.yaml` — security workflow layouts (static)

## Workflow

```bash
make          # regenerate layouts/claude-projects.yaml from generate-layout.sh
make install  # lint + regenerate + symlink tmux.conf + copy layouts to ~/.config/tmuxp/ + bootstrap TPM
make uninstall # remove installed layouts and ~/.tmux.conf symlink (keeps backups + TPM plugins)
make clean    # remove generated claude-projects.yaml + installed copies
make setup    # create ~/projects, ~/docker, ~/ops/{pentest,malware,osint,ctf}
make lint     # validate YAML syntax + tmux.conf parses
```

`layouts/claude-projects.yaml` is a build artifact — edit `generate-layout.sh`, not the YAML. The specialty layouts (`project.yaml`, `docker.yaml`, `pentest.yaml`, `malware-analysis.yaml`, `osint.yaml`, `ctf.yaml`) are static and copied as-is.

To add/remove projects, edit the `projects` array in `generate-layout.sh` (format: `"dirname:emoji:label:logfile"`), then run `make install`. `label` defaults to `dirname` if omitted; leave `logfile` empty for a plain shell pane instead of a tail.

## Launching layouts

All aliases use `tmuxp load -y <name>`. tmuxp creates the session and either attaches (outside tmux) or switches client (inside tmux).

```bash
tp                          # multi-project workspace (session: "claude")
th                          # show layout alias help
tp-new my-app               # single project (session: "my-app", cwd: ~/projects/my-app)
tctf                        # ctf workspace (session: "ctf", cwd: ~/ops/ctf)
tctf-new htb-apocalypse     # ctf engagement (session: "ctf-htb-apocalypse")
```

## Layout structure

Every project window follows the same pane pattern:
- `main-vertical` layout, `main-pane-width: 70%`
- Left 70%: `claude` pane (main workspace, focused)
- Right 30%, split horizontally:
  - `git` pane: `watch -n 5 -c 'git status -sb'`
  - `logs` pane: `tail -f <logfile>` (or plain shell when 4th field of project entry is empty)

Fixed windows on `claude-projects`: `🏠 cockpit` (btop + shell + ccusage) and `🧪 scratch` (two shells).

## Key config values

- `BASE_DIR` in `generate-layout.sh`: `~/projects`
- `SHOW_STATUSBAR` in `generate-layout.sh`: `"true"` to show, `"false"` to hide
- 4th field in each project entry: per-project log file path (relative to cwd); omit to get a plain shell pane

## Dependencies

- `tmux >= 3.2`
- `tmuxp` (install via `pipx install tmuxp` or distro package)
- `git`, `python3` (for lint)
- Linux clipboard: `wl-clipboard` (Wayland) or `xclip` / `xsel` (X11)
- Optional for cockpit window: `btop`, `bunx ccusage`

## Known caveats

- Mouse-drag selection: do **not** hold Shift while dragging — that bypasses tmux to terminal-native selection and captures the whole grid (including other panes). Drag without Shift uses tmux's pane-bounded selection. Alternative: `prefix Space` (tmux-thumbs) for keyboard hint copy.
- After `make install`, an already-running tmux server still uses the old conf — run `tmux source-file ~/.tmux.conf` or `tmux kill-server` and re-launch.
- TPM plugin install is best-effort during `make install`; if it fails, open tmux and press `prefix + I` to retry.
