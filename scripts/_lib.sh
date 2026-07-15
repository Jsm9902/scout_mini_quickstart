#!/usr/bin/env bash
set -Eeuo pipefail
retry() {
  local attempts="$1"; shift
  local delay=3
  local n=1
  until "$@"; do
    if (( n >= attempts )); then return 1; fi
    echo "[WARN] Command failed. Retry $n/$attempts in ${delay}s: $*"
    sleep "$delay"; n=$((n+1)); delay=$((delay*2))
  done
}
ensure_line() {
  local line="$1" file="$2"
  touch "$file"
  grep -Fqx "$line" "$file" || echo "$line" >> "$file"
}
