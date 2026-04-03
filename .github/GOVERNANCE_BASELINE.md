# Repository Governance Baseline

This baseline defines the GitHub governance and deployment access model for this repository.

## Current State Snapshot (2026-04-03 UTC)

- Repository: `aLearningProcess/fli-further-website` (private, default branch `main`).
- Actions permissions:
  - `enabled: true`
  - `allowed_actions: all`
  - `default_workflow_permissions: read`
  - `can_approve_pull_request_reviews: false`
- Environments:
  - `production` exists.
  - Deployment branch policy is limited to branch `main`.
- Actions secrets: none configured at repository scope.
- Actions variables: none configured at repository scope.
- Existing workflow `.github/workflows/deploy.yml` still deploys to Netlify and references:
  - `NETLIFY_SITE_ID`
  - `NETLIFY_AUTH_TOKEN`

## Governance Model

## Branch Governance

- Target: protect `main` with required pull requests and required status checks.
- Minimum controls:
  - no direct pushes to `main` except admin bypass in emergencies,
  - at least one review approval for production-impacting changes,
  - required CI checks before merge.

## Environment Governance

- Deployment environment is `production`.
- Deployments are restricted to branch `main` via deployment branch policy.
- Additional required-reviewer controls should be enabled when paid-plan protections are available.

## Deployment Identity Governance

- Workflow jobs must declare least-privilege `permissions`.
- Current deploy workflow pins job permissions to:
  - `contents: read`
- Replace long-lived deployment credentials with short-lived federated identity (OIDC) for GCP-only operations.

## Secret Decommission Plan (Netlify Cutover)

After GCP cutover is complete, remove all Netlify deployment artifacts:

1. Delete Actions secrets `NETLIFY_SITE_ID` and `NETLIFY_AUTH_TOKEN` (if present).
2. Remove Netlify-specific workflow steps from `.github/workflows/deploy.yml` (or remove the workflow entirely if replaced).
3. Remove `netlify.toml` if no longer required.

## Known Blocker

- Branch protection/rulesets API on this private repository currently returns HTTP 403:
  - "Upgrade to GitHub Pro or make this repository public to enable this feature."
- Owner action required:
  - either move repo visibility to public, or
  - upgrade billing plan to enable private-repo branch protection/rulesets.

