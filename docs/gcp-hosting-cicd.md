# FLI Further GCP Hosting CI/CD

This repository now deploys through GitHub Actions to Firebase Hosting on GCP using GitHub OIDC (no long-lived deploy keys).

## Hosting target shape

- Runtime target: Firebase Hosting in project `fli-further-public` (GCP-managed global edge).
- Security target: GitHub OIDC -> Workload Identity Federation -> deployment service account.
- This satisfies the "backend bucket or equivalent static hosting behind global HTTPS + CDN + managed TLS" intent through Firebase Hosting's managed edge runtime.

## Workflow

- Workflow file: `.github/workflows/deploy-gcp-hosting.yml`
- Validation gate: `scripts/ci/validate-static-site.sh`
- Hosting config: `firebase.json`
- DNS cutover runbook: `docs/gcp-dns-cutover-plan.md`

## Promotion model

1. `main` push triggers `static-validation`.
2. On success, deploy runs to `staging` preview channel (`staging-<sha>`).
3. Production deploy is a separate job bound to the GitHub `production` environment.
4. Require reviewers on the `production` environment in GitHub settings to enforce human approval before live deploy.

## Rollback

Use GitHub Actions `workflow_dispatch`:

- `target_environment=production`
- `deploy_ref=<previous-good-commit-sha>`

This redeploys the previous known-good static artifact set.

## Cache behavior and invalidation

- `*.html` responses are `Cache-Control: public, max-age=0, must-revalidate`.
- `css/**` is `Cache-Control: public, max-age=300`.
- Firebase Hosting propagates new versions globally on deploy.
- Emergency invalidation path: redeploy the current or previous good SHA.

## Required GitHub configuration

Set repository or environment variables:

- `GCP_WIF_PROVIDER` (Workload Identity Provider resource name)
- `GCP_WIF_SERVICE_ACCOUNT` (deployment service account email)
- `FIREBASE_PROJECT_ID` (or fallback `GCP_PROJECT_ID`)

Recommended environment protection:

- `staging`: optional reviewer gate.
- `production`: required reviewers + restricted branch/tag deployment rules.

## Security dependency

Production use is gated on credential containment work in [FLI-78](/FLI/issues/FLI-78):

- do not add or use static service-account keys for deployment
- do not mark production cutover complete until exposed credentials are revoked and replaced
- OIDC + WIF is the only accepted deployment auth path for this repo

## Netlify decommission checklist

- Removed workflow `.github/workflows/deploy.yml`.
- Removed `netlify.toml`.
- Remove stale GitHub secrets after cutover:
  - `NETLIFY_SITE_ID`
  - `NETLIFY_AUTH_TOKEN`
