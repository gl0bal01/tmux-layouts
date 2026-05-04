#!/usr/bin/env bash
# Idempotent TPM bootstrap. Clones TPM if missing, then installs declared plugins.
set -euo pipefail

TPM_DIR="${TPM_DIR:-$HOME/.tmux/plugins/tpm}"

if [[ ! -d "$TPM_DIR" ]]; then
  echo "[tpm] cloning to $TPM_DIR"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  echo "[tpm] already present at $TPM_DIR"
fi

if [[ -x "$TPM_DIR/bin/install_plugins" ]]; then
  echo "[tpm] installing/updating plugins"
  "$TPM_DIR/bin/install_plugins" || {
    echo "[tpm] install_plugins exited non-zero — open tmux and press 'prefix + I' to retry"
    exit 0
  }
fi
