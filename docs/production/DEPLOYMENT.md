# Janus Production Deployment Checklist

## Security boundary

Run the runtime and browser dashboard as separate services:

- `janus-runtime` binds to `127.0.0.1:8080` by default.
- `janus-web` serves the browser interface on port 5000.
- Put an HTTPS reverse proxy in front of the browser interface.
- Set `allowed_origins` to the exact HTTPS dashboard origin.
- Keep `JANUS_DEMO_MODE` unset in production.

## Required pre-launch configuration

1. Copy `config/janus.runtime.example.json` outside the repository.
2. Change database and payload paths for the appliance/server.
3. Set an exact dashboard HTTPS origin; do not use wildcard origins.
4. Configure the base64 Ed25519 **public** license verification key.
5. Do not place any license signing private key on a Janus customer appliance.
6. Store the database directory with restrictive operating-system permissions.
7. Enable encrypted, tested database backups.

## First-use sequence

1. Start `janus-runtime` with its production configuration.
2. Open the protected dashboard over HTTPS.
3. Use one-time bootstrap to create the first organization administrator.
4. Import a customer-specific signed license.
5. Create operator and reviewer accounts.
6. Create an engagement with written authorization reference, dates, approved assets, and approved services.
7. Certify each supported module with the exact installed SHA-256.
8. Run production execution only through the authorized runtime panel.

## Production execution conditions

Every execution must have a valid session, an execution-capable role, valid signed license, active engagement, exact approved target, production-approved module certification, and matching module hash. All authorization and execution outcomes are recorded in the audit log.

## Operational checks

- Review audit events daily.
- Rotate/revoke user access promptly when staff leave an engagement.
- Disable engagements when customer authorization expires or changes.
- Test restore procedures before relying on backups.
- Apply OS and Rust dependency security updates on a regular schedule.

## systemd deployment

Install the supplied templates from `deploy/systemd/` as:

```text
/etc/systemd/system/janus-runtime.service
/etc/systemd/system/janus-web.service
```

Create a non-login service account and writable state directories:

```bash
sudo useradd --system --home /var/lib/janus --shell /usr/sbin/nologin janus
sudo install -d -o janus -g janus -m 0750 /var/lib/janus /var/log/janus /etc/janus
sudo install -o root -g janus -m 0640 config/janus.runtime.example.json /etc/janus/janus.runtime.json
sudo install -o root -g janus -m 0640 config/janus.env.example /etc/janus/janus.env
sudo systemctl daemon-reload
sudo systemctl enable --now janus-runtime janus-web
```

Place the dashboard behind a customer-managed HTTPS reverse proxy. Do not expose the runtime port directly to the internet.
