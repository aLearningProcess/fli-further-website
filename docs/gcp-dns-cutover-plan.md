# FLI Further DNS Configuration (Current State)

This file documents the active DNS configuration for App Engine hosting.

## Active web DNS records

For `flifurther.com` (apex):

- `A` -> `216.239.32.21`
- `A` -> `216.239.34.21`
- `A` -> `216.239.36.21`
- `A` -> `216.239.38.21`
- `AAAA` -> `2001:4860:4802:32::15`
- `AAAA` -> `2001:4860:4802:34::15`
- `AAAA` -> `2001:4860:4802:36::15`
- `AAAA` -> `2001:4860:4802:38::15`

For `www.flifurther.com`:

- `CNAME` -> `ghs.googlehosted.com.`

## Verification commands

```bash
dig +short flifurther.com A
dig +short flifurther.com AAAA
dig +short www.flifurther.com CNAME
```

Expected App Engine custom domain mappings:

```bash
gcloud app domain-mappings describe flifurther.com --project fli-further-public --format="yaml(id,resourceRecords,sslSettings)"
gcloud app domain-mappings describe www.flifurther.com --project fli-further-public --format="yaml(id,resourceRecords,sslSettings)"
```

## TLS note

Managed certificates are provisioned by Google after DNS is correct. If HTTPS fails immediately after record changes, wait for certificate provisioning and recheck `sslSettings`.
