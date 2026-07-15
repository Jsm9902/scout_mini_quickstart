#!/usr/bin/env bash
set -Eeuo pipefail

mkdir -p "$WORKSPACE_DIR"

if [[ -d "$WORKSPACE_DIR/src" && -n "$(find "$WORKSPACE_DIR/src" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
  if [[ "$BACKUP_EXISTING_SRC" != "1" ]]; then
    echo "[ERROR] $WORKSPACE_DIR/src is not empty. Set BACKUP_EXISTING_SRC=1 or move it manually." >&2
    exit 1
  fi

  backup="$WORKSPACE_DIR/src.backup.$(date +%Y%m%d-%H%M%S)"
  echo "[INFO] Existing src directory found. Backing it up to: $backup"
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
rsync -a --delete "$tmp_dir/source/src/" "$WORKSPACE_DIR/src/"

required_paths=(
  scout_description
  scout_navigation
  scout_slam
  scout_web_monitor
  scout_ros2/scout_base
  scout_ros2/scout_msgs
  ugv_sdk
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$WORKSPACE_DIR/src/$path" ]]; then
    echo "[ERROR] Required source path missing: src/$path" >&2
    exit 1
  fi
done

echo "[OK] Scout Mini source packages copied to $WORKSPACE_DIR/src"
