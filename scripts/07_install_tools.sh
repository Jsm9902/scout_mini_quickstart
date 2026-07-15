#!/usr/bin/env bash
set -Eeuo pipefail

install_dir="$HOME/.local/bin"
mkdir -p "$install_dir"
for tool in "$ROOT_DIR"/tools/*.sh; do
  name="$(basename "$tool" .sh)"
  install -m 0755 "$tool" "$install_dir/$name"
done

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "[OK] Operator commands installed to $install_dir"
