# Architecture

## Service graph

```
        Railway HTTPS edge
              │
              ▼
   ┌─────────────────────────────────────────────┐
   │  degoog  (public domain :4444)               │  volume: /app/data
   │  one server process:                         │   - server-settings.json, repos.json
   │   - search UI + /search?q=…                   │   - autocomplete/ bus/ store/ themes/
   │   - settings + extensions API (password)     │   - installed extensions
   │   - readiness  /readyz                        │
   └─────────────────────────────────────────────┘
```

One service. The metasearch server aggregates results from many engines on demand; its configuration, installed
extensions and data live in SQLite/JSON on the `/app/data` volume.

## The degoog service

- Image: the official `ghcr.io/degoog-org/degoog`, pinned by digest, used unmodified.
- **Port:** `DEGOOG_PORT=4444`. The template sets `PORT=4444` (so Railway routes traffic and the health check to
  the right port), the public domain's target port to `4444`, and the health check to `/readyz`.
- **Settings password:** `DEGOOG_SETTINGS_PASSWORDS` (generated) gates every settings/extensions API. Reading or
  changing settings requires a session obtained by POSTing the password to `/api/settings/auth`. If the variable is
  unset, degoog generates a default password (and logs its status); the template sets it explicitly so it is known
  and strong. The search UI itself is open (it's a search engine); only the settings/extensions area is gated.
- **Volume:** `/app/data`. The image's entrypoint runs as root, `chown`s `/app/data` to a non-root user and drops
  privileges with `su-exec`, so it owns its data directory without any `RAILWAY_RUN_UID` override.

## Why the password matters

degoog's extensions run code on the server. On a public URL, an unlocked settings area would let anyone install an
extension and execute code — so protecting it is a security requirement, not a convenience. The template always
generates and sets `DEGOOG_SETTINGS_PASSWORDS`.
