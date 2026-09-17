# Security

## The settings password guards code execution

degoog's extension system **runs code on the server**. Its upstream documentation is explicit: "an unlocked
instance lets anyone install extensions, which runs code on the server." So the settings/extensions area must be
password-protected before the instance is exposed to the internet.

This template always generates `DEGOOG_SETTINGS_PASSWORDS` and sets it, so every settings/extensions API is gated:
reading or changing settings, or installing an extension, requires a session obtained by authenticating with the
password (`POST /api/settings/auth`). Verified in the smoke and live tests: reading settings without a session is
rejected (`401`), a wrong password does not authenticate, and the correct password unlocks the settings.

## What the template does

- **Generated settings password** (`DEGOOG_SETTINGS_PASSWORDS`) — the gate to the code-running extension system.
- **The dangerous escape hatch is off.** `DEGOOG_DANGEROUSLY_NO_PASSWORD` is never set.
- **Pinned image.** The official image is pinned by digest (see `UPSTREAM.md`); the application is unmodified.
- **Secret hygiene.** No secret is committed; the tests read the password from a mode-restricted file and never
  print it; the static test greps the tree for credential shapes.

## What you should do

- **Keep `DEGOOG_SETTINGS_PASSWORDS` secret and strong.** Anyone with it can install extensions and run code on your
  server. Rotate it by changing the variable.
- **Never enable `DEGOOG_DANGEROUSLY_NO_PASSWORD`** on an internet-facing instance.
- **Only install extensions you trust** — they run with the server's privileges.
- **Back up the volume** (`/app/data`) with Railway's volume backups.

## Reporting

For issues in degoog itself, report upstream. For issues specific to this template's packaging, open an issue on the
template repository.
