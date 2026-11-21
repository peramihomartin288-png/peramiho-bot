# Peramiho Bot: production and 24/7 architecture

## Important runtime constraint

This project uses Baileys to maintain a long-lived WhatsApp WebSocket connection. Run the Node.js process on an always-on VPS or a paid background-worker service with persistent storage. Do not move the WhatsApp socket into a Cloudflare Worker: Workers are event-driven and are not a replacement for a continuously running Node.js process with a persistent local filesystem.

No hosting design can promise 100% uptime. The goal is automatic recovery, durable session storage, monitoring, backups, and fast incident detection.

## Recommended service boundaries

| Service | Responsibility |
| --- | --- |
| GitHub | Source of truth, pull requests, code review, and CI checks. Keep main protected and deploy only reviewed commits. |
| VPS (Node.js 20+) | Runs the Baileys socket, command dispatcher, web panel/API, and PM2 or systemd supervisor. Use one process for the single WhatsApp account. |
| Persistent VPS volume | Holds the Baileys auth directory and required local runtime state. Restrict filesystem permissions and encrypt the disk/volume at the infrastructure layer. Never commit auth files or copy them into public logs. |
| Supabase Postgres | Future durable application records: user profiles, settings, audit events, command analytics, and service status. Enable RLS on exposed tables. Keep the service-role key only on the server. |
| Cloudflare | DNS, TLS, WAF/rate limiting, Tunnel or proxy to the VPS, and scheduled health checks. A Cron Trigger can call /healthz; it does not keep the WhatsApp process alive. |
| OpenRouter | Server-side AI model gateway. Use a server-side API key, model allow-list, request limits, timeout/retry policy, and redact private content before sending prompts. |
| Cloudinary | Recommended single media provider for image/video transformations and delivery. Store only provider asset IDs/URLs and metadata in Postgres. |
| Uploadcare | Optional alternative for a browser-first upload workflow. Do not integrate both Cloudinary and Uploadcare for the same media path unless a concrete requirement justifies the added cost and failure modes. |

## 24/7 deployment requirements

1. Use an always-on VPS with enough RAM/CPU for Node.js, FFmpeg, Sharp, and peak message load.
2. Mount a persistent volume and set DATA_DIR to that mount. Back up the auth directory securely; test restore procedures.
3. Run PM2 with ecosystem.config.js and configure PM2 startup, or use an equivalent systemd service.
4. Configure automatic restart with bounded backoff. Avoid multiple replicas of the same WhatsApp session; duplicate sockets can cause session conflicts.
5. Configure /readyz for process readiness and /healthz for actual WhatsApp connection health. Monitoring should alert on repeated failures rather than repeatedly restarting a healthy process.
6. Keep API keys in the host secret manager/environment settings, never in GitHub source, frontend bundles, or database rows.
7. Set up log rotation, disk-space alerts, memory alerts, dependency update review, and scheduled encrypted backups.
8. Use a staged deployment: deploy to a test instance first, verify pairing/session restore and message handling, then promote to production.

## Health endpoints

- GET /readyz: returns 200 once the bot manager is initialized, otherwise 503.
- GET /healthz: returns 200 only while a WhatsApp session is connected; returns 503 when disconnected. The response contains no phone number or session credentials.

Set the monitoring URL to https://YOUR_BOT_HOST/healthz. Cloudflare Cron Triggers execute on UTC; convert the intended local schedule accordingly.

## Supabase migration boundary

The existing PERAMIHO-VPS-PRO Supabase project currently contains VPS-management tables (vps_profiles, vps_providers, vps_instances, vps_requests, and related records), not Peramiho Bot tables. Do not repurpose it or overwrite its schema for this bot. Create or choose a dedicated project for Peramiho Bot, then migrate data deliberately with RLS policies and tested backups.

Do not store raw Baileys credentials in ordinary application tables. Keep the live auth state on the persistent VPS volume with restrictive permissions and infrastructure-level disk encryption; if remote backup is later required, encrypt the backup client-side before upload.

## Rollout checklist

- [ ] Confirm the dedicated Supabase project for the bot.
- [ ] Confirm the VPS provider, region, disk size, and budget.
- [ ] Configure Cloudflare DNS/Tunnel and health monitoring.
- [ ] Add Supabase URL and server-only key to VPS secrets.
- [ ] Add OpenRouter key and selected model to VPS secrets.
- [ ] Choose Cloudinary or Uploadcare (Cloudinary is the default recommendation here).
- [ ] Verify WhatsApp pairing, restart recovery, backup restore, and health alerts.
- [ ] Merge the pull request only after CI and manual smoke tests pass.