# 24/7 deployment (VPS / Docker)

## What this deployment guarantees

This repository is a **single-WhatsApp-number Phonephix Bot**. It needs an always-on Node.js process and persistent local storage for Baileys auth. Supabase, Cloudflare, GitHub Actions, Cloudinary, Uploadcare, and OpenRouter do not replace the always-on WhatsApp socket process.

The Docker Compose setup in this repository provides:
- restart after host/container restart (`restart: unless-stopped`);
- a named persistent volume mounted at `/data` for JSON database files and Baileys auth;
- graceful stop window;
- a local-only HTTP keep-alive/health check on port 3000;
- Node 20 runtime.

The HTTP check only proves that the keep-alive HTTP server responds. It does **not** prove WhatsApp is connected. Confirm the WhatsApp connection from container logs and the linked-device state.

## Required host

Use an Ubuntu/Debian VPS with stable internet, enough RAM/CPU for the enabled media commands, and a disk with monitoring and backups. A single WhatsApp session should have one running replica only. Do not scale this service horizontally: the repository enforces one process/session per data directory.

## Deploy

1. Install Docker Engine and the Docker Compose plugin on the VPS.
2. Clone this repository and enter its directory.
3. Create the environment file: `cp .env.example .env`.
4. Set `WHATSAPP_NUMBER` to the WhatsApp number with country code, digits only. Never commit `.env`.
5. Start: `docker compose up -d --build`.
6. Watch pairing and startup: `docker compose logs -f peramiho-bot`.
7. Complete WhatsApp Linked Devices pairing if this is a fresh data volume.
8. Verify: `docker compose ps` and `docker inspect --format='{{.State.Health.Status}}' peramiho-bot`.

## Recovery and updates

- Restart: `docker compose restart peramiho-bot`.
- Update: `git pull && docker compose up -d --build`.
- Logs: `docker compose logs --tail=200 peramiho-bot`.
- Backup: stop the container briefly or use a consistent volume snapshot, then securely back up the named volume. The volume contains WhatsApp authentication material and must be encrypted and access-restricted.
- Restore the same volume before starting a replacement container. Never run two copies against the same WhatsApp session.
- Configure host-level automatic security updates and external VPS uptime monitoring.

## Important platform and service notes

- Free ephemeral web hosting is not suitable for reliable 24/7 WhatsApp sessions. A persistent disk and an always-on paid instance or VPS are required.
- Cloudflare can protect a web endpoint or provide DNS/Tunnel; it does not host the persistent Baileys WebSocket runtime as a Worker.
- Supabase project `reqlqdgaxjgyyaifqizy` currently has a schema migration, but this repository's runtime still uses `database/fileStore.js` JSON persistence. Do not set Supabase environment variables expecting the bot to start using Postgres: a compatible adapter and data migration have not yet been implemented.
- OpenRouter can be configured through the existing `AI_API_KEY` and `AI_API_URL` settings after confirming the command implementation's OpenAI-compatible request format. Do not put API keys in source control.
- Cloudinary and Uploadcare are optional media services. The current repository has no verified production integration for them; do not add credentials until a concrete upload flow is selected.

## Go-live checklist

- [ ] VPS provisioned and SSH access secured.
- [ ] `.env` configured privately with `WHATSAPP_NUMBER`.
- [ ] Docker Compose service starts and remains healthy.
- [ ] WhatsApp linked and restored after a container restart.
- [ ] Persistent volume backup and restore tested.
- [ ] External uptime monitoring configured.
- [ ] CI passes on the exact release commit.
- [ ] Only one production replica is running.

A 24/7 design is not a guarantee of 100% uptime. VPS, network, WhatsApp service, and power outages can still interrupt connectivity. Monitor and alert on these dependencies.
