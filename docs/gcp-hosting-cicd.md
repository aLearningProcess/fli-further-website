# FLI Further GCP Hosting and Deploy Runbook

This repository is currently hosted on Google App Engine (Standard) in project `fli-further-public`.

## Current production topology

- Runtime: App Engine Standard (`python312`) using static handlers from `app.yaml`.
- Service: `default`.
- Domain mappings:
  - `flifurther.com`
  - `www.flifurther.com`
- Default host: `https://fli-further-public.uc.r.appspot.com`

## Source of truth files

- App Engine config: `app.yaml`
- Fallback WSGI app for non-static routes: `main.py`
- Containerized deploy script: `scripts/deploy_gcp.sh`
- Devcontainer wrapper script: `scripts/deploy_via_devcontainer.sh`
- Devcontainer image definition: `.devcontainer/Dockerfile`

## Deploying

Preferred command from repo root:

```bash
./scripts/deploy_via_devcontainer.sh
```

The wrapper builds/uses `fli-further-devcontainer`, authenticates to GCP from the local service account key JSON in the repo root, and deploys `app.yaml`.

Primary CI/CD path is GitHub Actions workflow `.github/workflows/deploy-gcp-hosting.yml`, which uses OIDC federation (`google-github-actions/auth@v2`) and deploys App Engine versions without long-lived JSON keys.

Direct command (inside the devcontainer) is:

```bash
./scripts/deploy_gcp.sh
```

## Operational health checks

Check active service split:

```bash
gcloud app services describe default --project fli-further-public --format="yaml(id,split)"
```

Check versions and traffic:

```bash
gcloud app versions list --service=default --project fli-further-public --format="table(id,version.createTime,traffic_split,servingStatus)"
```

Check recent App Engine errors:

```bash
gcloud logging read "resource.type=gae_app AND resource.labels.module_id=default AND severity>=ERROR" \
  --project=fli-further-public \
  --freshness=60m \
  --limit=50 \
  --format="table(timestamp,severity,resource.labels.version_id,textPayload)"
```

## Notes on legacy workflow

Legacy Netlify workflows have been retired. The active workflow `.github/workflows/deploy-gcp-hosting.yml` deploys App Engine for both staging preview versions and production promotions.
