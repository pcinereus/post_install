#!/bin/bash

set -euo pipefail

source install/functions.sh

# ─────────────────────────────────────────────────────────────────────
# Global Parameters
# ─────────────────────────────────────────────────────────────────────
REFRESH=0.5                            # refresh rate seconds
IDLE_SLEEP=0.05                        # key poller sleep time

# ─────────────────────────────────────────────────────────────────────
# Layout
# ─────────────────────────────────────────────────────────────────────
WIDTH=120                              # total width of the display
HALF_WIDTH=$((((WIDTH - 2) / 2) - 2))  # Width of a half window minus borders
SPACER=""                              # character for between columns
BANNER_HEIGHT=8
BANNER_TOP=1
LOGO_HEIGHT=8
LOGO_WIDTH=26
BANNER_MAIN_WIDTH="$((WIDTH - LOGO_WIDTH - 4))"
BANNER_INFO_LEFT="$((LOGO_WIDTH + 3))"
BANNER_INFO_WIDTH="$(( (BANNER_MAIN_WIDTH - 2) / 2))"
BANNER_PROGRESS_LEFT="$((BANNER_INFO_LEFT + BANNER_INFO_WIDTH + 2))"
BANNER_PROGRESS_WIDTH="$((BANNER_MAIN_WIDTH - BANNER_INFO_WIDTH - 2))"

TAB_ROW=$((LOGO_HEIGHT + 3))
CONTENT_TOP=$((TAB_ROW - 0))
CONTENT_HEIGHT=24
LOG_TOP=$((CONTENT_TOP + CONTENT_HEIGHT + 1))
LOG_HEIGHT=10

# ─────────────────────────────────────────────────────────────────────
# Global State
# ─────────────────────────────────────────────────────────────────────
RUNNING=true                            #running=true
CURRENT_STAGE="Initializing"            # Current stage in processing
distro=$(get_distro)                    # Distro name
DIRTY_TABS=true                         # Whether tabs need to be redrawn
DIRTY_CONTENT=true                      # Whether content needs to be redrawn

# ─────────────────────────────────────────────────────────────────────
# Files
# ─────────────────────────────────────────────────────────────────────
if [[ -f "install/installed_R_packages.txt" ]]; then
  rm "install/installed_R_packages.txt"
fi
if [[ -f "install/install.log" ]]; then
  rm "install/install.log"
fi
if [[ -f "install/stage.log" ]]; then
  rm "install/stage.log"
fi

# ─────────────────────────────────────────────────────────────────────
# Process the package data
# ─────────────────────────────────────────────────────────────────────
source install/data.sh

# ─────────────────────────────────────────────────────────────────────
# FIFO setup
# ─────────────────────────────────────────────────────────────────────
source install/keys.sh

# ─────────────────────────────────────────────────────────────────────
# Start the installation subshell
# ─────────────────────────────────────────────────────────────────────
source install/install.sh &

flag_file="install/install.flag"
# Wait for the flag file to be created
while [[ ! -f "$flag_file" ]]; do
  # echo "Waiting for the installation script to be ready..."
  sleep 1
done


# ─────────────────────────────────────────────────────────────────────
# Draw the main screen
# ─────────────────────────────────────────────────────────────────────
source install/ui.sh


# ─────────────────────────────────────────────────────────────────────
# The main loop
# ─────────────────────────────────────────────────────────────────────
while $RUNNING; do
  ##########################################
  # Handle async events
  ##########################################
    while read -t 0.01 event arg <&3; do
        case "$event" in
            QUIT)
                RUNNING=false
                ;;
            TAB)
                echo "$event"
                if [[ "$arg" -ne "$ACTIVE_TAB" ]]; then
                    ACTIVE_TAB="$arg"
                    DIRTY_TABS=true
                    DIRTY_CONTENT=true
                fi
                ;;
        esac
    done
  ##########################################
  # Partial redraw only
  ##########################################
  if $DIRTY_TABS; then
    draw_tabs
    DIRTY_TABS=false
  fi

  if $DIRTY_CONTENT; then
      draw_active_tab_panel "$ACTIVE_TAB"
    DIRTY_CONTENT=false
  fi

  update_banner
  # tput cup "$LOG_TOP" 0
  display_log_tail LOG_BLOCK
  printf "%s\n" "${LOG_BLOCK[@]}"

  sleep "$REFRESH"

done


## Place the cursor back to its original position (under the frame)
tput rc
