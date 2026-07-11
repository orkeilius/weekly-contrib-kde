# Weekly GitHub Contributions (KDE Plasma 6 widget)

Shows the last 7 days of your GitHub activity as 7 colored squares in the
panel — a KDE equivalent of the GNOME "Weekly Commits" extension.

## Install

**Requires Plasma 6.**

```bash
kpackagetool6 -t Plasma/Applet -i weekly-github-contributions.plasmoid
```

Then right-click your panel → **Add Widgets** → search for
**"Weekly GitHub Contributions"** → drag it onto the panel.

To upgrade after editing the files:

```bash
kpackagetool6 -t Plasma/Applet -u weekly-github-contributions.plasmoid
```

To remove:

```bash
kpackagetool6 -t Plasma/Applet -r com.github.weeklycontributions
```

If the panel doesn't pick up changes, restart Plasma:

```bash
systemctl restart --user plasma-plasmashell.service
```

## Configure

Right-click the widget → **Configure Weekly GitHub Contributions**:

- **GitHub username** — required.
- **Refresh interval** — how often it polls GitHub (default 30 min).

## How it works

It polls the public, unauthenticated GitHub REST endpoint
`GET /users/{username}/events/public` and buckets events into the last 7
calendar days. Push events count each commit in the push; every other
public event (PRs, issues, reviews, etc.) counts as 1. Counts are then
mapped to 5 shading levels, same idea as GitHub's own contribution graph.

**Limitations (it's intentionally basic):**
- Unauthenticated GitHub API calls are rate-limited to ~60/hour per IP —
  fine for a widget polling every 30 min, but don't set the refresh
  interval too low.
- Only *public* activity is visible — private repo contributions won't show
  up, since that requires an authenticated GraphQL query.
- The events API only returns recent public events (up to ~100 most
  recent), which is more than enough for a 7-day window unless you're
  extremely prolific.

## Notes for further work

If you want private contributions included too, you'd swap the fetch in
`contents/ui/main.qml` for GitHub's GraphQL API
(`contributionsCollection.contributionCalendar`) using a personal access
token, which you'd add as another config field (store it via
`plasmoid.configuration`, ideally through KWallet rather than plaintext).
That's a bit more work than this "basic" version, but the square-rendering
half of the widget wouldn't need to change at all.
