# Upstream and pinned versions

This template runs **degoog** from its official image, pinned by digest. There is no wrapper image — the
application is used unmodified and configured entirely through environment variables.

## degoog

- Project: https://github.com/degoog-org/degoog
- Licence: AGPL-3.0 (`licenses/DEGOOG-LICENSE`)
- Official image: `ghcr.io/degoog-org/degoog`
- Pinned: `ghcr.io/degoog-org/degoog:0.26.0`
  - digest `sha256:69e28fe2dc8008981b0ea8b9270f6b5b482d107b8a3dfa71d8acdac37f4b77c0` (multi-arch index; linux/amd64: `sha256:20874795da56014a8cdbea9cfae02286b33ab38dd83d772d348dd6fb2fd5f421`)

## Refreshing a digest

```bash
docker buildx imagetools inspect ghcr.io/degoog-org/degoog:<tag> --format '{{json .Manifest}}' | jq -r .digest
```

Update the pins here, in `compose.yaml`, and in `_audit/spec_degoog.py`, then re-run the tests and re-point the
template at the new tag. See `MAINTENANCE.md`.
