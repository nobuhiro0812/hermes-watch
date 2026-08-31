# hermes-watch

Watches the Hermes JP online store's public product sitemap every 5 minutes
and sends a push notification (via ntfy) when new or re-listed products appear.

- `check.sh` — fetches the sitemap, diffs against `state/products.txt`
- `state/products.txt` — snapshot of currently listed product URLs
- `reports/` — per-day log of detected new products
- `.github/workflows/watch.yml` — runs the check every 5 minutes

The notification channel (ntfy topic) is stored as a repository secret.
