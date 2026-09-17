# degoog on Railway

A one-click [Railway](https://railway.com) template that runs [degoog](https://github.com/degoog-org/degoog) — a
self-hosted, privacy-friendly **metasearch** engine that aggregates results from many search engines, with a
pluggable extension system. The settings/extensions area is protected by a **generated password**, so a stranger
cannot install code-running extensions on your instance.

This is a community-maintained template and is not affiliated with the degoog project.

- **Image:** the official `ghcr.io/degoog-org/degoog`, pinned by digest, used unmodified — see
  [UPSTREAM.md](UPSTREAM.md)
- degoog is **AGPL-3.0**; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for what that means for you.

## What you get

- One service: the degoog metasearch server, with its config and data on a `/app/data` volume.
- A **generated `DEGOOG_SETTINGS_PASSWORDS`** — the settings/extensions area requires it. This matters because
  installing an extension runs code on the server, so an unlocked instance on a public URL is a remote-code-execution
  risk. The template always sets it.

## Deploy

1. Click **Deploy on Railway** and wait for the service to go healthy.
2. Open the public domain and start searching.
3. To manage settings and extensions, open the settings area and enter `DEGOOG_SETTINGS_PASSWORDS` (copy it from the
   service's **Variables**).

## Use it

Search from the home page or `https://<your-domain>/search?q=...`. In the settings area (password-protected) you can
configure engines, install extensions, and tune ranking. Everything persists on the volume.

## Security

- Keep `DEGOOG_SETTINGS_PASSWORDS` secret and strong — it guards the code-running extension system. Rotate it by
  changing the variable.
- Do **not** set `DEGOOG_DANGEROUSLY_NO_PASSWORD` on a public instance. See [SECURITY.md](SECURITY.md).

## Repository layout

| Path | What |
|---|---|
| `compose.yaml` | Local test topology (the official image + a volume) |
| `tests/` | Static, smoke, persistence, and live (HTTPS) tests |
| `marketplace/OVERVIEW.md` | The marketplace overview shown on the template page |
| `RAILWAY_TEMPLATE.md` | The exact published template configuration |
| `UPSTREAM.md` · `SECURITY.md` · `ARCHITECTURE.md` · `MAINTENANCE.md` | Reference docs |

## Local development

```bash
docker compose up          # run the official image with a volume
tests/smoke.sh             # readyz, search results, settings password gate
tests/persistence.sh       # settings survive a restart
```

## Licence

The template's own files are MIT (`LICENSE`). degoog is AGPL-3.0; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
