#!/usr/bin/env bash
# Start the campsite watch in the background, sleep-proofed.
#
#   ./start.sh    launch it
#   ./stop.sh     stop it
#   ./status.sh   is it alive? what has it found?

set -uo pipefail
cd "$(dirname "$0")"

PIDFILE="watch.pid"
LOGFILE="watch.log"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "Already running (pid $(cat "$PIDFILE")). Run ./stop.sh first."
  exit 1
fi

# -i idle sleep, -m disk sleep, -s system sleep (while on AC power).
# This still does NOT beat closing the lid — macOS clamshell-sleeps
# regardless. Keep the lid open and the charger plugged in.
nohup caffeinate -ims ./campsite_watch.sh >> "$LOGFILE" 2>&1 &
echo $! > "$PIDFILE"

echo "Watch started (pid $(cat "$PIDFILE"))."
echo "Log:  $(pwd)/$LOGFILE"
echo "Tail: tail -f $(pwd)/$LOGFILE"
