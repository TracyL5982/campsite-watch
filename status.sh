#!/usr/bin/env bash
# Is the watch alive, and what has it turned up?

set -uo pipefail
cd "$(dirname "$0")"

PIDFILE="watch.pid"
LOGFILE="watch.log"

if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo "✅ Running (pid $(cat "$PIDFILE"))"
else
  echo "❌ Not running"
fi

if [[ -f "$LOGFILE" ]]; then
  echo
  echo "--- hits so far ---"
  grep -c "Reservable Campsites Matching" "$LOGFILE" | xargs echo "checks completed:"
  grep -E "recreation\.gov/camping/campsites" "$LOGFILE" | tail -20 || echo "(none yet)"
  echo
  echo "--- last 15 log lines ---"
  tail -15 "$LOGFILE"
fi
