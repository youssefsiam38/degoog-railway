# Maintenance

## Updating to a new upstream version

1. **Bump the pin.** Get the new digest (see `UPSTREAM.md`) and update `compose.yaml` and `_audit/spec_degoog.py`,
   and re-point the template's `degoog` image at the new tag.
2. **Run the tests locally.**
   ```bash
   tests/static.sh
   tests/smoke.sh
   tests/persistence.sh
   ```
3. **Re-verify on Railway.** Re-run the clean-room deploy + `tests/railway-smoke.sh` before updating the published
   template.

There is no wrapper image to build or publish — the template runs the official image unmodified, so CI only runs
the tests.

## Rebuilding the Railway template from scratch

The exact configuration is in `RAILWAY_TEMPLATE.md`. The generator spec is `_audit/spec_degoog.py`; the kit in
`_audit/` (`tplkit.py`) builds a skeleton, patches the template, and runs a clean-room deploy. Volumes, domains and
health checks are only set by `skeleton()`, so a change to those requires rebuilding from a skeleton; if
`verify_template` reports an empty volume right after create, delete the template and re-create it.

## Gotchas worth remembering

- **`DEGOOG_SETTINGS_PASSWORDS` must be set.** Without it degoog generates a default password, and extensions run
  code on the server — so the template always generates and sets it. Never set `DEGOOG_DANGEROUSLY_NO_PASSWORD`.
- **No `RAILWAY_RUN_UID` needed.** The image's entrypoint runs as root, `chown`s `/app/data`, and drops to a
  non-root user with `su-exec`, so it owns its volume regardless of Railway's root-mounted volume.
- **`PORT` = 4444 = `DEGOOG_PORT`** = the domain target port. Health check `/readyz`.
- **The settings API is session-based.** `POST /api/settings/auth {password}` returns a session cookie; the settings
  read/write endpoints require it (`GET /api/settings/general` is 401 without it).
- **The marketplace OVERVIEW needs `### Deployment Dependencies` as an H3** or Railway's publish rejects the readme.
