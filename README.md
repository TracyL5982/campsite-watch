# Campsite Watch — Cougar Rock, Sat Sept 5 2026

Watches recreation.gov for an opening at **Cougar Rock Campground** (Mount
Rainier) on **Sat Sept 5 → Sun Sept 6, 2026**, and pushes a notification to your
phone the moment one appears.

## Why only one campground and one date

Checked against recreation.gov's availability API on 2026-08-09:

| | |
|---|---|
| **Ohanapecosh** (232465) | Closed for all of 2026 — rehabilitation project, reopens 2027 |
| **White River** (259031) | First-come-first-served only. All 107 sites report `Not Reservable` on every date, so no watcher can ever catch one |
| **Cougar Rock** (232466) | Reservable **through Sept 13 only**. From Sept 14 all 176 sites flip to `Not Reservable` and it runs FCFS until it closes |

That rules out Sept 19 and Sept 26 entirely — they were never reservable, so a
watch on them would have stayed silent forever with no way to tell that apart
from "nothing available yet."

**"Not reservable" does not mean closed.** Those campgrounds are open and you can
camp there; the sites just aren't handed out through recreation.gov. For Sept 19
and Sept 26 the move is to drive up and claim a site first-come-first-served —
Friday morning, since Rainier's FCFS spots typically fill by midday.

Sept 5 is a genuinely live target: it currently shows 66 sites reserved and 64
not-yet-released, so it can open up via either a cancellation or a later release.

## One-time phone setup

1. Install **ntfy** — free, no account:
   [iOS](https://apps.apple.com/us/app/ntfy/id1625396347) ·
   [Android](https://play.google.com/store/apps/details?id=io.heckel.ntfy)
2. Open it, tap **+**, and subscribe to the topic name found in the local
   `.env` file (`cat .env`). It is not written down anywhere in this repo.
3. Allow notifications when prompted.

> ntfy topics are readable by anyone who knows the name, which is why this one
> is random and lives only in `.env` — gitignored, never committed. Don't share
> it. If it ever leaks, generate a new one with
> `openssl rand -hex 5`, update `.env`, update the `NTFY_TOPIC` repo secret, and
> resubscribe on your phone.

## How it runs

**Primary: GitHub Actions** — `.github/workflows/watch.yml` searches every ~10
minutes on GitHub's servers, so it keeps working with your laptop closed or off.
Nothing to start or babysit.

```sh
gh run list --workflow=watch.yml        # recent runs
gh workflow run watch.yml               # search right now
gh run view --log                       # what the last run saw
```

The `NTFY_TOPIC` repo secret holds the topic name; it is encrypted and not
visible in the public repo. Scheduled runs on the free tier are best-effort —
GitHub delays them under load, so real cadence is closer to 10-20 minutes.

**Backup: the local Mac watcher**, below. Only useful if you want a second
source of alerts; it needs the Mac awake and plugged in, and it does not share
"already notified" state with GitHub, so you may get duplicates.

## Running it locally

```sh
cd ~/Developer/campsite-watch
./start.sh      # launch in background, survives closing the terminal
./status.sh     # is it alive, and what has it found
./stop.sh       # stop it
tail -f watch.log
```

`start.sh` wraps the watcher in `caffeinate -i -s`, which blocks idle sleep while
it runs. Closing your laptop lid on battery will still sleep the machine — keep
it plugged in if you want overnight coverage.

## What it searches

One night — arrive **Sat 2026-09-05**, depart Sun 2026-09-06 — at Cougar Rock
(campground `232466`), re-checked every 10 minutes.

Olympic National Park is no longer watched; its IDs are kept in a comment in
`campsite_watch.sh` in case you want them back.

`--offline-search` keeps a record of what's already been reported, so a site
that stays open for hours notifies once rather than every 10 minutes.

## Checking whether a date is even reservable

Before adding any date, confirm it's in the reservation system at all —
otherwise you're waiting on something that can never arrive:

```sh
curl -s -H "User-Agent: Mozilla/5.0" \
  "https://www.recreation.gov/api/camps/availability/campground/232466/month?start_date=2026-09-01T00%3A00%3A00.000Z" |
python3 -c "
import json,sys,collections
d=json.load(sys.stdin); t=collections.defaultdict(collections.Counter)
for s in d['campsites'].values():
    for day,st in s['availabilities'].items(): t[day[:10]][st]+=1
for day in sorted(t): print(day, dict(t[day]))"
```

`Not Reservable` on every site means FCFS or out of season — nothing to watch
for. `Reserved` / `NYR` / `Available` mean the date is live.

## Tweaks

Both `campsite_watch.sh` and `.github/workflows/watch.yml` share the same two
knobs — change them in **both** places, or only one runner will follow:

- **Different dates?** Edit the `NIGHTS` list of `arrive:depart` pairs.
- **Fri + Sat together?** Widen a pair to span two days
  (`2026-09-05:2026-09-07`) and set `--nights 2`.
- **More campgrounds?** Add `--campground <id>` to `CAMPGROUNDS`.
- **Faster polling?** 5 minutes is camply's floor. Not recommended —
  recreation.gov may rate-limit you.

## Silence is ambiguous — know which kind you have

A watch on an unreservable date looks exactly like a watch on a reservable date
that hasn't opened up yet: nothing happens, no error. That is how Sept 19 and
Sept 26 nearly went unnoticed.

Before trusting a quiet watch, run the availability check above. If the date
shows anything other than all-`Not Reservable`, silence just means no
cancellation yet. If it's all `Not Reservable`, the watch is pointless and you
should switch to a first-come-first-served plan instead.

## When you get an alert

Click the notification — it opens the recreation.gov page for that exact site.
**Book immediately.** Popular Rainier/Olympic weekend cancellations are usually
gone within minutes. camply finds sites; it does not hold or book them.
