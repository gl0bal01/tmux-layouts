LAYOUTS_DIR := $(HOME)/.config/tmuxp
TMUX_CONF   := $(HOME)/.tmux.conf
TPM_DIR     := $(HOME)/.tmux/plugins/tpm
REPO_DIR    := $(abspath $(dir $(firstword $(MAKEFILE_LIST))))

GENERATED := layouts/claude-projects.yaml
STATIC    := layouts/project.yaml layouts/docker.yaml layouts/pentest.yaml \
             layouts/malware-analysis.yaml layouts/osint.yaml layouts/ctf.yaml
ALL       := $(GENERATED) $(STATIC)

LAYOUT_SCRIPT := $(shell test -f generate-layout.local.sh && echo generate-layout.local.sh || echo generate-layout.sh)

.PHONY: all install uninstall clean setup lint help list tpm

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all        Regenerate $(GENERATED) (default)"
	@echo "  install    Lint + regenerate + symlink tmux.conf + copy layouts + bootstrap TPM"
	@echo "  uninstall  Remove installed layouts and ~/.tmux.conf symlink (keeps backups + TPM)"
	@echo "  clean      Remove generated files locally and from $(LAYOUTS_DIR)/"
	@echo "  setup      Create ~/projects, ~/docker, ~/ops/{pentest,malware,osint,ctf}"
	@echo "  lint       Validate YAML syntax of all layouts and tmux.conf"
	@echo "  list       List installed layouts in $(LAYOUTS_DIR)/"
	@echo "  tpm        Bootstrap TPM and install plugins (idempotent)"
	@echo "  help       Show this message"
	@echo ""
	@echo "Layouts:"
	@echo "  claude-projects   Multi-project workspace (generated)"
	@echo "  project           Single project (template)"
	@echo "  docker            Docker / Compose workflow"
	@echo "  pentest           Penetration testing"
	@echo "  malware-analysis  Malware static / dynamic analysis"
	@echo "  osint             OSINT investigation"
	@echo "  ctf               CTF competition"

list:
	@echo "Installed layouts in $(LAYOUTS_DIR)/:"
	@ls $(LAYOUTS_DIR)/*.yaml 2>/dev/null | while read f; do basename "$$f" .yaml; done || echo "  (none)"

all: $(GENERATED)

$(GENERATED): $(LAYOUT_SCRIPT)
	bash $(LAYOUT_SCRIPT) > $@

lint: $(GENERATED)
	@command -v python3 >/dev/null || (echo "ERROR: python3 required for lint"; exit 1)
	@command -v tmux >/dev/null || (echo "ERROR: tmux required for lint"; exit 1)
	@echo "Checking YAML syntax..."
	@for f in $(ALL); do \
		if python3 -c "import sys, yaml; yaml.safe_load(open('$$f'))" 2>/dev/null; then \
			echo "  OK: $$f"; \
		else \
			echo "  FAIL: $$f"; python3 -c "import yaml; yaml.safe_load(open('$$f'))"; exit 1; \
		fi; \
	done
	@echo "Checking tmux.conf parses..."
	@out=$$(tmux -f tmux.conf -L _lint_$$$$ start-server \; kill-server 2>&1); \
		if echo "$$out" | grep -Eqi '^(.+:[0-9]+:.*)?(unknown|usage:|invalid|bad)'; then \
			echo "  FAIL: tmux.conf"; echo "$$out"; exit 1; \
		else \
			echo "  OK: tmux.conf"; \
		fi

install: lint $(ALL) tpm
	@mkdir -p $(LAYOUTS_DIR)
	@if [ -f $(TMUX_CONF) ] && [ ! -L $(TMUX_CONF) ]; then \
		ts=$$(date +%Y%m%d-%H%M%S); \
		mv $(TMUX_CONF) $(TMUX_CONF).bak.$$ts; \
		echo "Backed up existing ~/.tmux.conf -> $(TMUX_CONF).bak.$$ts"; \
	fi
	@ln -sfn $(REPO_DIR)/tmux.conf $(TMUX_CONF)
	@echo "Symlinked $(TMUX_CONF) -> $(REPO_DIR)/tmux.conf"
	@for f in $(ALL); do cp $$f $(LAYOUTS_DIR)/; done
	@echo "Copied layouts to $(LAYOUTS_DIR)/"
	@echo ""
	@echo "Done. Next:"
	@echo "  source $(REPO_DIR)/tmux-layouts.zsh        # in ~/.zshrc"
	@echo "  tmux source-file ~/.tmux.conf             # if tmux server already running"
	@echo "  th                                        # show layout help"

tpm:
	@if [ ! -d $(TPM_DIR) ]; then \
		echo "Bootstrapping TPM..."; \
		bash scripts/install-tpm.sh; \
	else \
		echo "TPM already installed at $(TPM_DIR) — running plugin install"; \
		"$(TPM_DIR)/bin/install_plugins" || echo "(plugin install non-fatal — open tmux + prefix I)"; \
	fi

uninstall:
	@for f in $(notdir $(ALL)); do rm -f $(LAYOUTS_DIR)/$$f; done
	@echo "Removed installed layouts from $(LAYOUTS_DIR)/"
	@if [ -L $(TMUX_CONF) ]; then rm $(TMUX_CONF); echo "Removed symlink $(TMUX_CONF)"; fi
	@echo "(Backups preserved. TPM kept at $(TPM_DIR) — remove manually if desired.)"

clean:
	rm -f $(GENERATED)
	@for f in $(notdir $(ALL)); do rm -f $(LAYOUTS_DIR)/$$f; done

setup:
	@mkdir -p $(HOME)/projects $(HOME)/docker
	@mkdir -p $(HOME)/ops/pentest $(HOME)/ops/malware $(HOME)/ops/osint $(HOME)/ops/ctf
	@echo "Created project + ops directories under $(HOME)/"
