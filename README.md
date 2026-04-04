# fli-further-website

Static website for FLI Further, deployed on Google App Engine in project `fli-further-public`.

## Quick deploy

```bash
./scripts/deploy_via_devcontainer.sh
```

## Key files

- `app.yaml`: App Engine static routing config.
- `main.py`: WSGI fallback for non-static routes.
- `scripts/deploy_gcp.sh`: GCP deploy script.
- `.devcontainer/`: Tooling image with `gcloud` and `firebase-tools`.
- `docs/gcp-hosting-cicd.md`: Current hosting and operations runbook.
- `docs/gcp-dns-cutover-plan.md`: Current DNS records and verification commands.
