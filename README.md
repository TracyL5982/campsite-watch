# Campsite Watch — Mount Rainier, Sept 2026

Watches recreation.gov for openings on three specific Saturday nights —
**Sept 5, Sept 19, Sept 26** — across the three Mount Rainier campgrounds, and
pushes a notification to your phone the moment one appears.

Each night is searched as its own exact one-night window (arrive Sat, leave
Sun). A single wide range with `--weekends` would also match Sept 11/12/18/25,
so this avoids alerts for nights you didn't ask about.

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

Three one-night windows, re-checked every 10 minutes:

| Arrive | Depart |
|---|---|
| Sat 2026-09-05 | Sun 2026-09-06 |
| Sat 2026-09-19 | Sun 2026-09-20 |
| Sat 2026-09-26 | Sun 2026-09-27 |

Across the three Mount Rainier campgrounds:

| Campground | ID |
|---|---|
| Cougar Rock | 232466 |
| Ohanapecosh | 232465 |
| White River | 259031 |

IDs verified live against recreation.gov. Olympic National Park is no longer
watched; its IDs are kept in a comment in `campsite_watch.sh` in case you want
them back.

`--offline-search` keeps a record of what's already been reported, so a site
that stays open for hours notifies once rather than every 10 minutes.

## Tweaks

Both `campsite_watch.sh` and `.github/workflows/watch.yml` share the same two
knobs — change them in **both** places, or only one runner will follow:

- **Different dates?** Edit the `NIGHTS` list of `arrive:depart` pairs.
- **Fri + Sat together?** Widen a pair to span two days
  (`2026-09-05:2026-09-07`) and set `--nights 2`.
- **More campgrounds?** Add `--campground <id>` to `CAMPGROUNDS`.
- **Faster polling?** 5 minutes is camply's floor. Not recommended —
  recreation.gov may rate-limit you.

## A caveat on late-September dates

Rainier campgrounds close for the season in early-to-mid October, and exact
closing dates shift year to year. Sept 5 is comfortably in season. If Sept 19 or
26 ever fall outside a campground's operating window, that campground simply
never returns a hit for that night — the watch stays silent rather than erroring,
so silence isn't proof the watcher is broken. Check the campground page on
recreation.gov if a date goes suspiciously quiet.

## When you get an alert

Click the notification — it opens the recreation.gov page for that exact site.
**Book immediately.** Popular Rainier/Olympic weekend cancellations are usually
gone within minutes. camply finds sites; it does not hold or book them.
