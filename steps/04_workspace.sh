#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
mkdir -p "$WORKSPACE_DIR"
repo_dir="$WORKSPACE_DIR/.quickstart_source"
if [[ -d "$repo_dir/.git" ]]; then
  if [[ "$SOURCE_POLICY" == "update" || "$FORCE" == "1" ]]; then
    git -C "$repo_dir" fetch --all --prune
    git -C "$repo_dir" checkout "$SOURCE_BRANCH"
    git -C "$repo_dir" reset --hard "origin/$SOURCE_BRANCH"
  fi
else
  rm -rf "$repo_dir"
  git clone --branch "$SOURCE_BRANCH" --depth 1 "$SOURCE_REPOSITORY" "$repo_dir"
fi
if [[ -d "$WORKSPACE_DIR/src" && -n "$(find "$WORKSPACE_DIR/src" -mindepth 1 -maxdepth 1 2>/dev/null)" ]]; then
  case "$SOURCE_POLICY" in
    backup) backup_path "$WORKSPACE_DIR/src"; mkdir -p "$WORKSPACE_DIR/src" ;;
    update) mkdir -p "$WORKSPACE_DIR/src" ;;
    abort) log_error "Existing src found: $WORKSPACE_DIR/src"; exit 1 ;;
    *) log_error "Invalid SOURCE_POLICY=$SOURCE_POLICY"; exit 1 ;;
  esac
else
  mkdir -p "$WORKSPACE_DIR/src"
fi
rsync -a --delete "$repo_dir/src/" "$WORKSPACE_DIR/src/"
for p in scout_navigation scout_slam scout_web_monitor scout_description ugv_sdk; do
  find "$WORKSPACE_DIR/src" -name package.xml -print0 | xargs -0 grep -l "<name>$p</name>" >/dev/null || { log_error "Required package missing: $p"; exit 1; }
done
log_success "Workspace sources prepared."
