# Reverse proxy exposure

Recommended production mode. MISP binds to `127.0.0.1:8080` and `127.0.0.1:8443` by default; point a same-host reverse proxy to `https://127.0.0.1:8443`.

For a reverse proxy on another host, use the installer's explicit `--proxy-bind-address` option and source-restricted firewall guidance. The lifecycle manager does not modify host firewall policy, and it never widens the loopback default implicitly.
