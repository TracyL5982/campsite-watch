#!/usr/bin/env bash
# Stop the campsite watch.

set -uo pipefail
cd "$(dirname "$0")"

PIDFILE="watch.pid"

if [[ ! -f "$PIDFILE" ]]; then
  echo "No pid file — nothing to stop."
  exit 0
fi

PID="$(cat "$PIDFILE")"
if kill -0 "$PID" 2>/dev/null; then
  # Kill the whole process group so camply dies with caffeinate.
  kill -- "-$(ps -o pgid= "$PID" | tr -d ' ')" 2>/dev/null || kill "$PID"
  echo "Stopped (pid $PID)."
else
  echo "Process $PID wasn't running."
fi

rm -f "$PIDFILE"
