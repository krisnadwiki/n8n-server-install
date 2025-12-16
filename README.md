# n8n Server Installation with Docker Compose

Complete setup guide for installing n8n workflow automation platform on Ubuntu Server using Docker Compose.

## 📋 Prerequisites

- Ubuntu Server (20.04 LTS or later recommended)
- Root or sudo access
- Minimum 2GB RAM
- 10GB free disk space
- Internet connection

## 🚀 Quick Start

### Automated Installation

Run the automated installation script:

```bash
sudo bash install.sh
```

This script will:
- Install Docker and Docker Compose
- Create configuration files
- Set up the n8n environment

### Manual Installation

If you prefer to install manually:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/krisnadwiki/n8n-server-install.git
   cd n8n-server-install
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env
   nano .env
   ```

3. **Configure your settings in `.env`:**
   - Set `N8N_BASIC_AUTH_USER` (default: admin)
   - Set `N8N_BASIC_AUTH_PASSWORD` (change the default!)
   - Set `N8N_HOST` (your domain or IP)
   - Set `WEBHOOK_URL` (your domain or IP with protocol)
   - Set `GENERIC_TIMEZONE` (e.g., America/New_York, Europe/London)

4. **Start n8n:**
   ```bash
   docker compose up -d
   ```
   or for older Docker Compose versions:
   ```bash
   docker-compose up -d
   ```

5. **Access n8n:**
   Open your browser and navigate to:
   ```
   http://your-server-ip:5678
   ```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `N8N_BASIC_AUTH_ACTIVE` | Enable basic authentication | `true` |
| `N8N_BASIC_AUTH_USER` | Basic auth username | `admin` |
| `N8N_BASIC_AUTH_PASSWORD` | Basic auth password | `changeme` |
| `N8N_HOST` | Host address | `0.0.0.0` |
| `N8N_PROTOCOL` | Protocol (http/https) | `http` |
| `N8N_PORT` | Port number | `5678` |
| `WEBHOOK_URL` | Webhook URL | `http://your-domain.com/` |
| `GENERIC_TIMEZONE` | Timezone | `UTC` |

### Docker Compose Configuration

The `docker-compose.yml` file includes:
- **n8n service**: Main application container
- **Persistent volume**: For workflow and credential storage
- **Network**: Isolated bridge network
- **Port mapping**: Exposes port 5678
- **Local files mount**: `/files` directory for file operations

## 🔧 Management Commands

### Using the Management Script (Recommended)

For easier management, use the included `n8n-manager.sh` script:

```bash
# Start n8n
./n8n-manager.sh start

# Stop n8n
./n8n-manager.sh stop

# Restart n8n
./n8n-manager.sh restart

# View logs
./n8n-manager.sh logs

# Check status
./n8n-manager.sh status

# Update to latest version
./n8n-manager.sh update

# Create backup
./n8n-manager.sh backup

# Restore from backup
./n8n-manager.sh restore

# Show help
./n8n-manager.sh help
```

### Using Docker Compose Directly

Alternatively, use Docker Compose commands directly:

#### Start n8n
```bash
docker compose up -d
```

#### Stop n8n
```bash
docker compose down
```

#### View logs
```bash
docker compose logs -f n8n
```

#### Restart n8n
```bash
docker compose restart
```

#### Update n8n
```bash
docker compose pull
docker compose up -d
```

## 📦 Data Management

### Backup

Backup your n8n data using the management script (recommended):
```bash
./n8n-manager.sh backup
```

Or manually:
```bash
# Create backup directory
mkdir -p backups

# Get the volume name
VOLUME_NAME=$(docker compose config --volumes | grep n8n_data)

# Backup volume data
docker run --rm \
  -v ${VOLUME_NAME}:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C /data .
```

### Restore

Restore from backup using the management script (recommended):
```bash
./n8n-manager.sh restore
```

Or manually:
```bash
# Stop n8n
docker compose down

# Get the volume name
VOLUME_NAME=$(docker compose config --volumes | grep n8n_data)

# Restore data
docker run --rm \
  -v ${VOLUME_NAME}:/data \
  -v $(pwd)/backups:/backup \
  alpine sh -c "rm -rf /data/* && tar xzf /backup/your-backup-file.tar.gz -C /data"

# Start n8n
docker compose up -d
```

## 🔒 Security Recommendations

1. **Change default password**: Always change the default password in `.env`
2. **Use HTTPS**: Configure a reverse proxy (nginx/Caddy) with SSL/TLS
3. **Firewall**: Configure UFW or iptables to restrict access
4. **Updates**: Regularly update n8n to the latest version
5. **Backups**: Schedule regular backups of your data

### Setting up UFW Firewall

```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow 22

# Allow n8n port (or only from specific IP)
sudo ufw allow 5678
# Or restrict to specific IP:
# sudo ufw allow from YOUR_IP to any port 5678

# Check status
sudo ufw status
```

## 🌐 Production Setup with SSL

For production environments, it's recommended to use a reverse proxy with SSL:

### Using Nginx with Let's Encrypt

1. Install Nginx and Certbot:
   ```bash
   sudo apt install nginx certbot python3-certbot-nginx
   ```

2. Create Nginx configuration:
   ```bash
   sudo nano /etc/nginx/sites-available/n8n
   ```

3. Add configuration:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:5678;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

4. Enable site and get SSL certificate:
   ```bash
   sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   sudo certbot --nginx -d your-domain.com
   ```

5. Update `.env` file:
   ```
   N8N_PROTOCOL=https
   WEBHOOK_URL=https://your-domain.com/
   ```

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs n8n

# Check if port is already in use
sudo netstat -tlnp | grep 5678
```

### Permission issues
```bash
# Fix permissions for local files
sudo chown -R 1000:1000 n8n-local-files
```

### Reset n8n
```bash
# Warning: This will delete all workflows and credentials
docker compose down -v
docker compose up -d
```

## 📚 Additional Resources

- [n8n Official Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [n8n Docker Hub](https://hub.docker.com/r/n8nio/n8n)

## 📝 License

This installation guide is provided as-is. n8n is licensed under the [Sustainable Use License](https://github.com/n8n-io/n8n/blob/master/LICENSE.md).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## ⚠️ Disclaimer

This setup is intended for self-hosting n8n. Please review n8n's license and terms of service before deploying in production environments.
