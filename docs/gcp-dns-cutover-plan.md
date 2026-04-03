# FLI Further DNS Cutover Plan (GCP Hosting)

This runbook covers DNS cutover for `flifurther.com` and `www.flifurther.com` to the GCP hosting path implemented in this repository.

## Scope and target

- Scope: web traffic for apex (`flifurther.com`) and `www`.
- Target platform: Firebase Hosting in GCP project `fli-further-public`.
- Non-web DNS records must remain unchanged (mail/auth/verification records).

## Dependency gate

Do not execute production cutover until [FLI-78](/FLI/issues/FLI-78) is resolved (exposed credential containment and replacement).

## Current DNS baseline (observed 2026-04-02 America/New_York)

- `flifurther.com A` -> `3.33.130.190`, `15.197.148.33`
- `www.flifurther.com CNAME` -> `flifurther.com.`
- `flifurther.com MX` -> Google Workspace (`aspmx.l.google.com` + alt hosts)
- `flifurther.com TXT` includes SPF and Google site verification
- Nameservers -> `ns57.domaincontrol.com`, `ns58.domaincontrol.com`

Current live web response at apex/`www` serves a JavaScript redirect to `/lander`, and `/lander` returns `403`. This differs from repository content.

## Cutover decision required before DNS change

Choose one and document it in the release note:

1. Serve repo `index.html` at `/` after cutover (recommended baseline).
2. Preserve redirect behavior to `/lander` by adding an explicit hosting redirect/rewrite before production deploy.

## DNS change plan

1. Export current zone records from registrar DNS UI for rollback reference.
2. In Firebase Hosting custom domain setup, add `flifurther.com` and `www.flifurther.com`.
3. Apply exactly the DNS records Firebase provides for apex/`www` (ownership TXT + A/AAAA/CNAME as prompted).
4. Keep existing MX/TXT/other non-web records unchanged.
5. Use low TTL during change window where registrar permits.

## Verification checklist

After DNS changes propagate:

- `dig +short flifurther.com A` resolves to Firebase-provided apex target.
- `dig +short www.flifurther.com CNAME` or A/AAAA resolves per Firebase instructions.
- `curl -sS https://flifurther.com/` returns expected homepage or approved redirect behavior.
- `curl -sS https://www.flifurther.com/` matches apex behavior.
- `dig +short flifurther.com MX` remains Google Workspace values.
- `dig +short flifurther.com TXT` still includes required SPF/verification entries.
- TLS certificate status in Firebase domain panel is `Connected`.

## Rollback

If cutover fails:

1. Reapply pre-cutover apex and `www` web records:
   - `flifurther.com A`: `3.33.130.190`, `15.197.148.33`
   - `www.flifurther.com CNAME`: `flifurther.com.`
2. Re-validate apex and `www` responses.
3. Leave non-web records unchanged.
4. Capture incident details and attach to the issue thread before retrying.
