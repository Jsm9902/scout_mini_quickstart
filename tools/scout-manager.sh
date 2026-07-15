#!/usr/bin/env bash
set -Eeuo pipefail
while true; do
cat <<'MENU'

========== Scout Mini Manager ==========
1. Start SLAM
2. Start Navigation + Industrial Safety
3. Start Web SLAM
4. Start Web Navigation
5. Check robot
6. Stop robot
7. Verify installation
0. Exit
========================================
MENU
read -rp "Select: " choice
case "$choice" in
1) exec start_slam;; 2) exec start_navigation;; 3) exec start_web_slam;; 4) exec start_web_navigation;;
5) check_robot;; 6) stop_robot;;
7) CONFIG_FILE="${CONFIG_FILE:-$HOME/.config/scout_mini_quickstart/quickstart.env}" echo "Run from repository: ./quickstart.sh --verify-only";;
0) exit 0;; *) echo "Invalid selection";; esac
done
