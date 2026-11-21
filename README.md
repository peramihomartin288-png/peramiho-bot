<div align="center">

<img src="https://i.ibb.co/N26rv2qt/27bc5646a677.jpg" alt="Phonephix Bot" width="420" />

# 👑 Phonephix Bot

**Secure · Fast · Powerful · Premium**

Developed by **Dvary** — Connect · Chat · Enjoy

[Join the Phonephix Pro channel](https://whatsapp.com/channel/0029VbCRC9b5fM5cruU8PF2M)

### 🚀 Get the bot in one click

<a href="https://github.com/Dvaryteacher123/phonephix-bof/fork"><img src="https://img.shields.io/badge/🍴_Fork_this_repo-24292f?style=for-the-badge&logo=github&logoColor=white" alt="Fork" height="42"></a>
<a href="https://github.com/Dvaryteacher123/phonephix-bof/archive/refs/heads/main.zip"><img src="https://img.shields.io/badge/⬇️_Download_ZIP-2ea44f?style=for-the-badge&logo=github&logoColor=white" alt="Download ZIP" height="42"></a>

<a href="https://render.com/deploy?repo=https://github.com/Dvaryteacher123/phonephix-bof"><img src="https://render.com/images/deploy-to-render-button.svg" alt="Deploy to Render" height="42"></a>
<a href="https://railway.com/new"><img src="https://railway.com/button.svg" alt="Deploy on Railway" height="42"></a>
<a href="#-vps--panel"><img src="https://img.shields.io/badge/🖥️_Deploy_on_VPS-0b5fff?style=for-the-badge&logo=linux&logoColor=white" alt="Deploy on VPS" height="42"></a>

</div>

> **Quick steps:** ① **Fork** (or **Download ZIP**) → ② press **Deploy to Render**, **Deploy on Railway** or follow the **VPS** guide → ③ set `WHATSAPP_NUMBER` → ④ open the **Logs**, copy your **pair code** and link it on WhatsApp.

---

## ✨ How it works

One bot = one WhatsApp number. No website, no Telegram.

1. **Deploy** the bot (Render, Railway, Heroku, VPS or a panel).
2. Set your number in **Environment Variables** (`WHATSAPP_NUMBER`), e.g. `255712345678`. No `+`, no spaces.
3. Open the **Logs**. The bot will show an **8-character PAIR CODE**.
4. On WhatsApp: **Settings → Linked Devices → Link a Device → Link with phone number instead**, then enter the code.
5. Once linked, your number automatically follows the Phonephix Pro channel.

---

## 🚀 Where to deploy

### Render
[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/Dvaryteacher123/phonephix-bof)

Press the button above (it reads `render.yaml` and fills the settings for you).

**After you press Deploy:**
1. Render asks for `WHATSAPP_NUMBER`. Type your number with country code, no `+`, no spaces (e.g. `255712345678`).
2. Press **Apply** and wait for the build to finish.
3. Open **Logs** and copy the **8-character PAIR CODE**.
4. On WhatsApp: **Settings → Linked Devices → Link a Device → Link with phone number instead**, then enter the code.

Wrong number? Open the **Environment** tab, fix `WHATSAPP_NUMBER`, then **Manual Deploy → Restart**.

Prefer to do it by hand?
1. Create **New → Web Service** (or **Background Worker**) and connect your repo.
2. **Build Command:** `npm install`
3. **Start Command:** `npm start`
4. Open the **Environment** tab → **Add Environment Variable** → set `WHATSAPP_NUMBER`.
5. Add a **Persistent Disk**, e.g. mount path `/data`, then set `DATA_DIR=/data`.
6. Click **Deploy**, then open **Logs** to get your pair code.

> The free Render plan has no persistent disk, so you will have to pair again after every restart. Add a Persistent Disk (paid) to keep your session.

### Railway
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new)

Press the button, choose **Deploy from GitHub repo**, and pick your fork. Then:

1. Open the **Variables** tab → set `WHATSAPP_NUMBER`.
2. Add a **Volume**, e.g. mount path `/data`, then set `DATA_DIR=/data`.
3. Open **Deployments → Logs** to get your pair code.

### Heroku
1. Create a new app and connect your repo.
2. **Settings → Config Vars** → set `WHATSAPP_NUMBER`.
3. A `Procfile` is included (`worker: node server.js`). Turn on the **worker** dyno, not web.
4. Open **More → View logs** to get your pair code.
5. Heroku has no persistent disk, so you will have to pair again after every restart. For long-term use, choose Render, Railway or a VPS.

### 🖥️ VPS / Panel

Works on any Ubuntu / Debian VPS (needs Node.js 20 or newer).

**1. Install Node.js, Git and PM2**
```bash
sudo apt update && sudo apt install -y git curl
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm i -g pm2
```

**2. Get the bot**
```bash
git clone https://github.com/Dvaryteacher123/phonephix-bof.git
cd phonephix-bof
npm install
```

**3. Add your number**
```bash
cp .env.example .env
nano .env
```
Set `WHATSAPP_NUMBER=255712345678` (country code, no `+`, no spaces). Save with `CTRL+O`, `ENTER`, then `CTRL+X`.

**4. Start the bot and get the pair code**
```bash
pm2 start ecosystem.config.js
pm2 logs
```
Copy the **8-character PAIR CODE** from the logs and link it on WhatsApp (**Linked Devices → Link with phone number instead**).

**5. Keep it running after reboot**
```bash
pm2 save && pm2 startup
```

A VPS keeps the session on its own disk, so you do **not** need to pair again after a restart.

**Useful commands:** `pm2 logs` (see logs), `pm2 restart all` (restart), `pm2 stop all` (stop).

**Panel (Pterodactyl and similar):** upload the files, set **Startup** to `npm start`, add `WHATSAPP_NUMBER` in the **Environment / Variables** section, then open the **Console** to get the pair code.

---

## 🔑 Environment Variables (where to put them)

| Platform | Where to set them |
|---|---|
| Render | **Environment** tab |
| Railway | **Variables** tab |
| Heroku | **Settings → Config Vars** |
| VPS / Panel | A `.env` file (copy from `.env.example`) or the panel's Environment section |

> ⚠️ Never commit your `.env` file to GitHub. Keep every secret (keys, numbers) in Environment Variables only.

### Required

| Variable | Description |
|---|---|
| `WHATSAPP_NUMBER` | Your number with country code, e.g. `255712345678`. Needed on Render, Railway and Heroku |
| `DATA_DIR` | Folder on a persistent disk (e.g. `/data`). Without it you must pair again after every redeploy |

### Optional

| Variable | Description |
|---|---|
| `BOT_NAME` | Bot name |
| `DEFAULT_PREFIX` | Command prefix, e.g. `.` |
| `BOT_MODE` | `public` or `private` |
| `BOT_TIMEZONE` | e.g. `Africa/Dar_es_Salaam` |
| `BOT_FOOTER` | Footer text shown on messages |
| `AI_API_KEY` | AI key (Groq, OpenAI, OpenRouter) for the `.ai` commands |
| `AI_API_URL` | e.g. `https://api.groq.com/openai/v1` |
| `AI_MODEL` | e.g. `llama-3.1-8b-instant` |
| `WEATHER_API_KEY` | OpenWeather key for `.weather` |
| `MUSIC_PROVIDERS` | Order of music sources |
| `SAAVN_API_URLS` | JioSaavn API addresses, comma separated |
| `PIPED_INSTANCES` | Piped instances, comma separated |
| `MUSIC_API_BASES` | Extra YouTube-download API addresses |
| `YT_PROXY` | Optional proxy for YouTube |

The full list is in `.env.example`. After changing any variable, **restart** the bot.

---

## 🌷 Menu

`.menu` shows every command in categories. `.menu <category>` shows a single category.

---

## 🔒 Protection

- Only one session can run at a time.
- The bot is locked to the first number that linked. If a different number logs in, the session is deleted.
- Every shipped `.js` file is fingerprinted in a signed manifest. If any of them is **edited or deleted**, the bot shuts down.
- Adding new files (your own commands, docs) is fine. Put your own commands in `phonephix/custom/`.
- Pair-code requests are limited (4 per hour, 45 seconds apart).

> To see which file triggered a shutdown, set `INTEGRITY_DEBUG=true` and start the bot once.

---

## 🍴 Fork & Download

| | |
|---|---|
| **Fork** (recommended, you get your own copy on GitHub) | [**Fork this repo**](https://github.com/Dvaryteacher123/phonephix-bof/fork) |
| **Download ZIP** (no GitHub account needed) | [**Download ZIP**](https://github.com/Dvaryteacher123/phonephix-bof/archive/refs/heads/main.zip) |

After forking:

1. Deploy your fork with any option above (Render / Railway / Heroku / VPS).
2. Put **your own** keys in Environment Variables. Never commit `.env`.
3. Do not edit the shipped `.js` files (see **Protection**).

<div align="center">

**POWERED BY DVARY**

Connect · Chat · Enjoy

</div>
