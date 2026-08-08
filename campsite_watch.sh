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
# Mount Rainier National Park (rec area #2835)
COUGAR_ROCK=232466      # Cougar Rock Campground
OHANAPECOSH=232465      # Ohanapecosh Campground
WHITE_RIVER=259031      # White River Campground

# Olympic National Park (rec area #2881)
HOH=247592              # Hoh Rainforest Campground
KALALOCH=232464         # Kalaloch
MORA=247591             # Mora Campground
SOL_DUC=251906          # Sol Duc Hot Springs Resort Campground
FAIRHOLME=259084        # Fairholme Campground
STAIRCASE=247586        # Staircase Campground

# -------------------------------------------------------------
# THE WATCH
# -------------------------------------------------------------
# Window 2026-08-21 -> 2026-09-06 with --weekends resolves to the
# six Fri/Sat booking nights of your three target weekends:
#   Aug 21, Aug 22, Aug 28, Aug 29, Sep 4, Sep 5
#
# --nights 1        : any single night counts as a hit.
#                     Change to 2 to require both Fri AND Sat.
# --search-forever  : keeps hunting after the first hit, so you
#                     hear about better sites that free up later.
#                     It won't re-notify about the same campsite.
# --polling-interval: minutes between checks. 10 is the sweet
#                     spot; 5 is the floor camply allows and
#                     risks rate-limiting from recreation.gov.

camply campsites \
  --campground "$COUGAR_ROCK" \
  --campground "$OHANAPECOSH" \
  --campground "$WHITE_RIVER" \
  --campground "$HOH" \
  --campground "$KALALOCH" \
  --campground "$MORA" \
  --campground "$SOL_DUC" \
  --campground "$FAIRHOLME" \
  --campground "$STAIRCASE" \
  --start-date 2026-08-21 \
  --end-date   2026-09-06 \
  --nights 1 \
  --weekends \
  --polling-interval 10 \
  --search-forever \
  --notifications ntfy
