# Railway template configuration

The template's exact configuration. Reproduce it from this file if it ever has to be rebuilt.

| | |
|---|---|
| Name | degoog |
| Code | `degoog` |
| Template id | `ccab710a-f7f3-48f7-8a2c-9a9dfb5829f3` |
| Deploy URL | https://railway.com/deploy/degoog |
| Category | Other |
| Card description | Self-hosted, privacy-friendly metasearch engine with extensions. |
| Icon | `assets/icon.png` |
| Overview markdown | `marketplace/OVERVIEW.md` (Railway enforces its section headings) |

Generated values use Railway's `secret()` function: `hexN` is `${{secret(N, "abcdef0123456789")}}` and `alnumN` is
`${{secret(N, "a-zA-Z0-9")}}` spelled out. Alphanumeric passwords are used wherever a value is embedded in a
connection URL, so nothing needs percent-encoding. Images are referenced by tag, because the template generator
rejects digests; `UPSTREAM.md` records the digests.

## Services

### `degoog`

| Field | Value |
|---|---|
| Source | `ghcr.io/degoog-org/degoog:0.26.0` |
| Public domain | target port 4444 |
| Volume | `/app/data` |
| Healthcheck | `/readyz`, timeout from `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` |
| Restart policy | on failure, 10 retries |

| Variable | Value |
|---|---|
| `DEGOOG_PORT` | `4444` |
| `PORT` | `4444` |
| `DEGOOG_SETTINGS_PASSWORDS` | generated, alnum32 |
| `RAILWAY_HEALTHCHECK_TIMEOUT_SEC` | `300` |

## Notes

- **Single service, official image unmodified (AGPL-3.0).** No wrapper. The search UI is open; only the
  settings/extensions area is gated.
- **`DEGOOG_SETTINGS_PASSWORDS` (generated) is a security requirement, not a convenience.** degoog's extensions run
  code on the server, so an unlocked settings area on a public URL is a remote-code-execution risk. The template
  always sets it. The escape hatch `DEGOOG_DANGEROUSLY_NO_PASSWORD` is never set. Settings are session-based:
  `POST /api/settings/auth {password}` → cookie; the settings read/write endpoints need it.
- **No `RAILWAY_RUN_UID` needed.** The image's entrypoint runs as root, `chown`s `/app/data`, and drops to a
  non-root user with `su-exec`, so it owns its volume regardless of Railway's root-mounted volume.
- **`PORT` = 4444 = `DEGOOG_PORT`** = the domain target port; health check `/readyz`. Config/data persist on
  `/app/data`. Search: `GET /search?q=...`.
