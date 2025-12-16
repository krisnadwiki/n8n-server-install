# Quick Start Guide

## One-Line Installation

For a quick installation on Ubuntu Server:

```bash
curl -fsSL https://raw.githubusercontent.com/krisnadwiki/n8n-server-install/main/install.sh | sudo bash
```

Or download and run:

```bash
wget https://raw.githubusercontent.com/krisnadwiki/n8n-server-install/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

## After Installation

1. **Edit configuration:**
   ```bash
   nano .env
   ```
   
   Change at minimum:
   - `N8N_BASIC_AUTH_PASSWORD` - Set a strong password
   - `WEBHOOK_URL` - Set your server's URL

2. **Start n8n:**
   ```bash
   docker compose up -d
   ```

3. **Access n8n:**
   - Open browser: `http://YOUR_SERVER_IP:5678`
   - Login with credentials from `.env` file

## Common Commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# Logs
docker compose logs -f n8n

# Update
docker compose pull && docker compose up -d

# Restart
docker compose restart
```

## Need Help?

See the full [README.md](README.md) for detailed documentation.
