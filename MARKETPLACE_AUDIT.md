# Marketplace audit

A record of the diligence behind publishing this template.

## Identity

- Template: **degoog** — a self-hosted metasearch engine with a pluggable extension system.
- Upstream: [degoog-org/degoog](https://github.com/degoog-org/degoog), AGPL-3.0, active (~2k stars).

## Licence

- **AGPL-3.0** (`licenses/DEGOOG-LICENSE`). Running it as a template is permitted; the image is used unmodified, so
  no additional source-disclosure obligation is created by this template (that would arise only from your own
  modifications offered over a network). See `THIRD_PARTY_NOTICES.md`.

## Security review

- **The code-running extension system is gated.** degoog's extensions execute code on the server; an unlocked
  settings area on a public URL is a remote-code-execution risk. The template always generates and sets
  `DEGOOG_SETTINGS_PASSWORDS`, so the settings/extensions API requires a password-authenticated session. Verified
  live: reading settings without a session → 401, a wrong password → not authenticated, the correct password →
  unlocked. `DEGOOG_DANGEROUSLY_NO_PASSWORD` is never set.
- **Secret hygiene.** The password is generated; the tests read it from a mode-restricted file and never print it;
  the static test greps the tree for credential shapes.
- **Reproducible.** The image is pinned by digest.

## Reproducibility & tests

- `tests/static.sh` (15 checks): syntax, shellcheck, compose shape, digest pin, settings-password wiring, no
  no-password escape hatch, secret scan.
- `tests/smoke.sh` (8 checks): readiness, home page, a search returns aggregated results, and the settings area is
  password-gated (401 without a session, wrong password rejected, correct password unlocks).
- `tests/persistence.sh` (4 checks): a settings value written through the API survives a restart (the `/app/data`
  volume).
- `tests/railway-smoke.sh`: the same flows over HTTPS against the deployed template.
- CI runs static + smoke + persistence on every push (no image build — the official image is used unmodified).

## Deploy-time inputs

- `DEGOOG_SETTINGS_PASSWORDS` — generated (the settings/extensions password).
- Everything else is fixed by the template (port, health check, volume). No required human input beyond clicking
  deploy.

## Verdict

Shippable. A self-contained, reproducible metasearch deployment whose search works and whose code-running
settings/extensions area is password-gated — both verified on a live Railway deployment.
