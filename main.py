def app(environ, start_response):
    redirect_paths = {"/index.html", "/free-guide", "/start-here", "/about"}
    if environ.get("PATH_INFO", "") in redirect_paths:
        status = "301 Moved Permanently"
        body = b"Moved Permanently"
        location = "/"
    else:
        status = "404 Not Found"
        body = b"Not Found"
        location = None

    headers = [
        ("Content-Type", "text/plain; charset=utf-8"),
        ("Content-Length", str(len(body))),
        ("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload"),
        ("X-Content-Type-Options", "nosniff"),
        ("X-Frame-Options", "DENY"),
        ("Referrer-Policy", "strict-origin-when-cross-origin"),
        ("Permissions-Policy", "camera=(), microphone=(), geolocation=()"),
        ("Content-Security-Policy", "default-src 'self'; base-uri 'self'; frame-ancestors 'none'; object-src 'none'; form-action 'self'; img-src 'self' data:; style-src 'self' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com data:; connect-src 'self'; upgrade-insecure-requests"),
    ]
    if location is not None:
        headers.append(("Location", location))

    start_response(status, headers)
    return [body]
