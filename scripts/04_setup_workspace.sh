#!/usr/bin/env bash
set -Eeuo pipefail
mkdir -p "$WORKSPACE_DIR"
source_checkout="$WORKSPACE_DIR/.source_checkout"
src="$WORKSPACE_DIR/src"

prepare_checkout() {
  if [[ -d "$source_checkout/.git" ]]; then
    git -C "$source_checkout" remote set-url origin "$SOURCE_REPO"
    git -C "$source_checkout" fetch --depth 1 origin "$SOURCE_BRANCH"
    git -C "$source_checkout" checkout -B "$SOURCE_BRANCH" "origin/$SOURCE_BRANCH"
    git -C "$source_checkout" reset --hard "origin/$SOURCE_BRANCH"
    git -C "$source_checkout" clean -fdx
  else
    rm -rf "$source_checkout"
    git clone --depth 1 --branch "$SOURCE_BRANCH" "$SOURCE_REPO" "$source_checkout"
  fi
  [[ -d "$source_checkout/src" ]] || { echo "[ERROR] Source repository has no src/ directory."; exit 1; }
}

case "$SOURCE_POLICY" in
  update)
    prepare_checkout
    mkdir -p "$src"
    rsync -a --delete "$source_checkout/src/" "$src/"
    ;;
  backup)
    if [[ -d "$src" && -n "$(find "$src" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
      backup="$WORKSPACE_DIR/src.backup.$(date +%Y%m%d-%H%M%S)"
      mv "$src" "$backup"
      echo "[INFO] Existing source backed up: $backup"
    fi
    prepare_checkout
    mkdir -p "$src"
    rsync -a "$source_checkout/src/" "$src/"
    ;;
  abort)
    [[ ! -d "$src" || -z "$(find "$src" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]] || { echo "[ERROR] $src is not empty."; exit 1; }
    prepare_checkout
    mkdir -p "$src"
    rsync -a "$source_checkout/src/" "$src/"
    ;;
  *) echo "[ERROR] SOURCE_POLICY must be update, backup, or abort."; exit 1;;
esac

required=(scout_description scout_navigation scout_slam scout_web_monitor scout_ros2/scout_base scout_ros2/scout_msgs ugv_sdk)
for p in "${required[@]}"; do [[ -e "$src/$p" ]] || { echo "[ERROR] Source missing: $p"; exit 1; }; done

echo "[OK] Source synchronized to $src"
