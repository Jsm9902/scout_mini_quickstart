#!/usr/bin/env bash
set -Eeuo pipefail

mkdir -p "$WORKSPACE_DIR"
if [[ -d "$WORKSPACE_DIR/src/.git" ]]; then
  echo "[ERROR] $WORKSPACE_DIR/src is itself a Git repository. Move or back it up first." >&2
  exit 1
fi

if [[ -d "$WORKSPACE_DIR/src" && -n "$(find "$WORKSPACE_DIR/src" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  backup="$WORKSPACE_DIR/src.backup.$(date +%Y%m%d-%H%M%S)"
  echo "[INFO] Existing src directory found. Backing up to $backup"
  mv "$WORKSPACE_DIR/src" "$backup"
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

git clone --depth 1 --branch "$SOURCE_BRANCH" "$SOURCE_REPO" "$tmp_dir/source"
if [[ ! -d "$tmp_dir/source/src" ]]; then
  echo "[ERROR] Source repository does not contain src/." >&2
  exit 1
fi
mkdir -p "$WORKSPACE_DIR/src"
cp -a "$tmp_dir/source/src/." "$WORKSPACE_DIR/src/"

echo "[OK] Source packages copied to $WORKSPACE_DIR/src"
