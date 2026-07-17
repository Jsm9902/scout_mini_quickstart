#!/usr/bin/env bash
set -Eeuo pipefail

require_command() {
  command -v "$1" >/dev/null 2>&1 || { echo "[ERROR] Required command not found: $1"; return 1; }
}

sudo_keepalive() {
  sudo -v
  while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
}

apt_install() {
  local packages=("$@")
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
}

safe_source() {
  local file="$1"
  [[ -f "$file" ]] || { echo "[ERROR] Missing setup file: $file"; return 1; }
  local had_nounset=0
  case "$-" in *u*) had_nounset=1; set +u ;; esac
  # shellcheck disable=SC1090
  source "$file"
  [[ $had_nounset -eq 1 ]] && set -u
}

check_internet() {
  curl -fsSL --max-time 10 https://raw.githubusercontent.com/ros/rosdistro/master/ros.key >/dev/null
}

backup_path() {
  local path="$1"
  local stamp
  stamp="$(date +%Y%m%d_%H%M%S)"
  mv "$path" "${path}.backup_${stamp}"
}

write_file_sudo() {
  local target="$1"
  local tmp
  tmp="$(mktemp)"
  cat > "$tmp"
  sudo install -m 0644 "$tmp" "$target"
  rm -f "$tmp"
}
