#!/usr/bin/env bash
# =============================================================
#  Campsite Watch — Mount Rainier & Olympic National Park
#  Target weekends: Aug 22, Aug 29, Sept 5 (2026)
#  Tool: camply (https://github.com/juftin/camply)
# =============================================================
#
#  You don't run this file directly — run ./start.sh instead.
#  That launches this in the background, sleep-proofed, and
#  logs to watch.log. See README.md.
#
# -------------------------------------------------------------

set -uo pipefail

export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"

# -------------------------------------------------------------
# NOTIFICATIONS — ntfy.sh (free, no account)
# -------------------------------------------------------------
# The topic name lives in .env, which is gitignored — ntfy topics are
# readable by anyone who knows the name, so it must not end up in a
# public repo. Your phone is subscribed to whatever is in that file.
if [[ ! -f "$(dirname "$0")/.env" ]]; then
  echo "Missing .env — expected NTFY_TOPIC=... next to this script." >&2
  exit 1
fi
set -a
# shellcheck disable=SC1091
source "$(dirname "$0")/.env"
set +a

# -------------------------------------------------------------
# CAMPGROUND IDs — all verified live against recreation.gov
# -------------------------------------------------------------
# Cougar Rock, Mount Rainier NP. The only campground here worth
# watching — verified against recreation.gov's availability API
# on 2026-08-09:
#   Ohanapecosh (232465) closed all 2026 for rehab, reopens 2027
#   White River (259031) is first-come-first-served only; all 107
#     sites report "Not Reservable" on every date, so no watcher
#     can ever catch one
CAMPGROUNDS="--campground 232466"

# Olympic is no longer watched. If you ever want it back:
#   Hoh Rainforest 247592 · Kalaloch 232464 · Mora 247591
#   Sol Duc 251906 · Fairholme 259084 · Staircase 247586

# -------------------------------------------------------------
# THE WATCH
# -------------------------------------------------------------
# One night: arrive Sat Sept 5, leave Sun Sept 6.
#
# Sept 19 and Sept 26 were dropped because they cannot be reserved.
# Cougar Rock's last reservable night is 2026-09-13; from Sept 14 all
# 176 sites flip to "Not Reservable" and the campground runs
# first-come-first-served until it closes. For those weekends you have
# to drive up and claim a site, ideally Friday morning.
NIGHTS="2026-09-05:2026-09-06"

# --nights 1 : one night per hit. Widen the pair above (e.g.
#              2026-09-04:2026-09-06) plus --nights 2 for Fri+Sat.
while :; do
  for pair in $NIGHTS; do
    echo "--- arriving ${pair%%:*} ---"
    camply campsites \
      $CAMPGROUNDS \
      --start-date "${pair%%:*}" \
      --end-date   "${pair##*:}" \
      --nights 1 \
      --notifications ntfy \
      --search-once \
      --offline-search \
      --offline-search-path "$(dirname "$0")/camply_campsites.json"
  done
  sleep 600   # 10 minutes; 5 is camply's floor and risks rate-limiting
done
