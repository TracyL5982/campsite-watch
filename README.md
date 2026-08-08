# Campsite Watch — Rainier & Olympic, Aug/Sept 2026

Watches recreation.gov for Fri/Sat openings on your three target weekends
(**Aug 22, Aug 29, Sept 5**) across 9 campgrounds in Mount Rainier and Olympic
National Parks, and pushes a notification to your phone the moment one appears.

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

Window `2026-08-21` → `2026-09-06` with `--weekends`, which resolves to exactly
six booking nights: Aug 21, 22, 28, 29 and Sep 4, 5. Polls every 10 minutes and
keeps going after the first hit (`--search-forever`), so you'll also hear about
better sites that free up later. It won't notify twice about the same campsite.

| Park | Campground | ID |
|---|---|---|
| Mt Rainier | Cougar Rock | 232466 |
| Mt Rainier | Ohanapecosh | 232465 |
| Mt Rainier | White River | 259031 |
| Olympic | Hoh Rainforest | 247592 |
| Olympic | Kalaloch | 232464 |
| Olympic | Mora | 247591 |
| Olympic | Sol Duc Hot Springs Resort | 251906 |
| Olympic | Fairholme | 259084 |
| Olympic | Staircase | 247586 |

All IDs verified live against recreation.gov on 2026-08-05.

## Tweaks

Edit `campsite_watch.sh`:

- **Want both Fri and Sat?** Change `--nights 1` to `--nights 2`.
- **Fewer campgrounds?** Delete the `--campground "$NAME"` lines you don't want.
- **Faster polling?** `--polling-interval 5` is the floor camply allows. Not
  recommended — recreation.gov may rate-limit you.

## When you get an alert

Click the notification — it opens the recreation.gov page for that exact site.
**Book immediately.** Popular Rainier/Olympic weekend cancellations are usually
gone within minutes. camply finds sites; it does not hold or book them.
