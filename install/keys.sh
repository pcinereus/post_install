#!/bin/bash

############################################
# Cleanup and shutdown
############################################
cleanup() {
  RUNNING=false
  kill "$poller_pid" 2>/dev/null || true
  exec 3>&-
  rm -f "$FIFO"
  stty sane < /dev/tty 2>/dev/null || true
  # clear
  # echo "Exited cleanly."
}

############################################
# Async key poller
############################################
poll_keys() {
  stty -echo -icanon time 0 min 0 < /dev/tty

  while true; do
    if read -rsn1 key < /dev/tty; then
      case "$key" in
        q|Q)
          echo "QUIT" >&3
          ;;
        $'\e')
            echo "QUIT" >&3
            ;;
        # s|d|m|r|p)
        #   echo "$key" >&3
        s) echo "TAB 0" >&3 ;;
        d) echo "TAB 1" >&3 ;;
        m) echo "TAB 2" >&3 ;;
        r) echo "TAB 3" >&3 ;;
        p) echo "TAB 4" >&3 ;;
        o) echo "TAB 5" >&3 ;;
      esac
    fi
    sleep "$IDLE_SLEEP"
  done
}

FIFO="/tmp/postinstall_keys.$$"
mkfifo "$FIFO"
exec 3<>"$FIFO"

trap cleanup EXIT
trap cleanup INT TERM
# Start the key poller in the background
poll_keys &
poller_pid=$!
