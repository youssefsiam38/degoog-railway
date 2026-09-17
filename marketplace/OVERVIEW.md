# Deploy and Host degoog on Railway

degoog is an open-source, privacy-friendly metasearch engine: it aggregates results from many search engines behind
one interface, with a pluggable extension system for customizing engines, ranking and integrations. This template
deploys degoog with its settings and extension area protected by a generated password. It is a community-maintained
template and is not affiliated with the degoog project.

## About Hosting degoog

degoog is a single server that renders the search UI, runs the metasearch, and hosts a settings/extensions area.
Its extensions run code on the server — so an instance whose settings area is left unlocked on a public URL can be
made to execute arbitrary code by anyone who finds it. degoog stores its configuration, installed extensions and
data on disk.

This template runs degoog on Railway with a generated `DEGOOG_SETTINGS_PASSWORDS` (so the settings and extension
area is always password-protected), its data persisted on a volume, and the port and health check wired. It runs the
official image unmodified, pinned by digest.

## Common Use Cases

- A private, self-hosted metasearch front-end that aggregates several engines without tracking you.
- A customizable search instance where you install extensions to add engines, adjust ranking, or integrate tools.
- A shareable search page for a team, behind your own settings password for administration.

## Dependencies for degoog Hosting

- Nothing external — degoog is a single self-contained service that stores its data on the volume.

### Deployment Dependencies

- degoog: https://github.com/degoog-org/degoog (AGPL-3.0)
- Template repository and tests: https://github.com/youssefsiam38/degoog-railway

### Implementation Details

degoog runs upstream's official image, pinned by digest and unmodified. The template generates
`DEGOOG_SETTINGS_PASSWORDS` and sets it so the settings/extensions area (where installing an extension runs code on
the server) always requires a password-authenticated session, never enables the `DEGOOG_DANGEROUSLY_NO_PASSWORD`
escape hatch, persists degoog's config and data on the `/app/data` volume, and wires `PORT`/`DEGOOG_PORT`, the
public domain and the `/readyz` health check. The image's entrypoint owns its own data directory, so no run-as-root
override is needed.

Tested in CI and on a live deployment of this template: the app is ready, a search returns aggregated results, the
settings area rejects access without a session and a wrong password while the correct password unlocks it, and a
settings value written through the API survives a redeploy.

After deploying, open the public domain and start searching. To manage settings and extensions, open the settings
area and enter `DEGOOG_SETTINGS_PASSWORDS` (copy it from the service's variables).

## Why Deploy degoog on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you
don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying degoog on Railway, you are one step closer to supporting a complete full-stack application with minimal
burden. Host your servers, databases, AI agents, and more on Railway.
