#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/logging.sh"
mkdir -p "$HOME/.local/lib/scout-mini" "$HOME/.local/bin"
install -m 0755 "$ROOT_DIR/commands/_common" "$HOME/.local/lib/scout-mini/_common"
for src in "$ROOT_DIR"/commands/scout-*; do
  name=$(basename "$src")
  sed 's#$(dirname "$0")/_common#$HOME/.local/lib/scout-mini/_common#' "$src" > "$HOME/.local/bin/$name"
  chmod +x "$HOME/.local/bin/$name"
done
line='export PATH="$HOME/.local/bin:$PATH"'
grep -Fqx "$line" "$HOME/.bashrc" || echo "$line" >> "$HOME/.bashrc"
log_success "Operational commands installed."
