# N8N Server Installation Guide

## Table of Contents
- [System Requirements](#system-requirements)
- [Installation Steps](#installation-steps)
  - [1. Verify Docker Installation](#1-verify-docker-installation)
  - [2. Check Your Server IP Address](#2-check-your-server-ip-address)
  - [3. Create Project Directory](#3-create-project-directory)
  - [4. Create Data Directory with Proper Permissions](#4-create-data-directory-with-proper-permissions)
  - [5. Create Environment Configuration File](#5-create-environment-configuration-file)
  - [6. Create Docker Compose Configuration](#6-create-docker-compose-configuration)
  - [7. Verify Folder Permissions](#7-verify-folder-permissions)
  - [8. Start the Services](#8-start-the-services)
  - [9. Check Container Status](#9-check-container-status)
  - [10. Configure Firewall](#10-configure-firewall-if-ufw-is-enabled)
- [Access Your Applications](#access-your-applications)
- [Maintenance Commands](#maintenance-commands)
- [Troubleshooting](#troubleshooting)
- [Security Recommendations](#security-recommendations)
- [Backup & Restore](#backup--restore)
- [Support](#support)

## System Requirements
- Docker Engine (latest version)
- Docker Compose V2
- Ubuntu Server 24.04 LTS (or compatible Linux distribution)
- Minimum 2GB RAM
- 10GB available disk space

## Installation Steps

### 1. Verify Docker Installation

First, verify that Docker and Docker Compose are installed:

```bash
docker --version
docker compose version
```

**Expected output example:**
```
Docker version 29.1.3, build f52814d
Docker Compose version v5.0.0
```

### 2. Check Your Server IP Address

```bash
hostname -I
```

Note your server's IP address. You'll need this for the configuration.

### 3. Create Project Directory

```bash
mkdir n8n-server
cd n8n-server
```

### 4. Create Data Directory with Proper Permissions

```bash
mkdir n8n-data
sudo chown -R 1000:1000 n8n-data
sudo chmod -R 755 n8n-data
```

### 5. Create Environment Configuration File

Create the `.env` file:

```bash
nano .env
```

Paste the following configuration and **modify the highlighted values**:

```env
# n8n Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=Admin
N8N_BASIC_AUTH_PASSWORD=StrongPassword     # CHANGE THIS to a strong password
N8N_HOST=192.168.1.100                      # CHANGE THIS to your server IP
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_SECURE_COOKIE=false
NODE_ENV=production
```

**Important:** Replace the following values:
- `N8N_BASIC_AUTH_PASSWORD`: Set a strong password for n8n login
- `N8N_HOST`: Set to your server's IP address (from step 2)

Save and exit (Ctrl+X, then Y, then Enter).

### 6. Create Docker Compose Configuration

Create the `docker-compose.yml` file:

```bash
nano docker-compose.yml
```

Paste the following content:

```yaml
services:
  n8n:
    image: n8nio/n8n
    restart: always
    container_name: n8n-server 
    ports:
      - "5678:5678"
    env_file:
      - .env
    volumes:
      - ./n8n-data:/home/node/.n8n

  portainer:
    image: portainer/portainer-ce:latest
    restart: always
    container_name: portainer
    ports:
      - "9000:9000"
      - "8000:8000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
```

Save and exit (Ctrl+X, then Y, then Enter).

### 7. Verify Folder Permissions

Check the permissions of your directories:

```bash
ls -la
```

**Expected output should look like:**
```
drwxr-xr-x  2 1000 1000 4096 Dec 16 10:30 n8n-data
-rw-r--r--  1 user user  300 Dec 16 10:25 .env
-rw-r--r--  1 user user  450 Dec 16 10:28 docker-compose.yml
```

### 8. Start the Services

```bash
sudo docker compose up -d
```

### 9. Check Container Status

```bash
sudo docker compose ps
```

**Expected output:**
```
NAME          IMAGE                          STATUS          PORTS
n8n-server    n8nio/n8n                      Up 2 minutes    0.0.0.0:5678->5678/tcp
portainer     portainer/portainer-ce:latest  Up 2 minutes    0.0.0.0:8000->8000/tcp, 0.0.0.0:9000->9000/tcp
```

### 10. Configure Firewall (if UFW is enabled)

Check firewall status:

```bash
sudo ufw status
```

If UFW is active, allow the required ports:

```bash
sudo ufw allow 5678/tcp
sudo ufw allow 9000/tcp
sudo ufw allow 8000/tcp
sudo ufw reload
```

## Access Your Applications

After successful installation, you can access:

### n8n Workflow Automation
- **URL:** `http://YOUR-SERVER-IP:5678`
- **Username:** Admin (or as configured in .env)
- **Password:** As set in `N8N_BASIC_AUTH_PASSWORD`

### Portainer (Docker Management)
- **URL:** `http://YOUR-SERVER-IP:9000`
- **First time:** Create admin user on first access

## Maintenance Commands

### Check Container Status
```bash
sudo docker compose ps
```

### View Container Logs
```bash
# View n8n logs
sudo docker compose logs n8n

# View Portainer logs
sudo docker compose logs portainer

# Follow logs in real-time
sudo docker compose logs -f n8n
```

### Restart Services
```bash
# Restart all services
sudo docker compose restart

# Restart specific service
sudo docker compose restart n8n
sudo docker compose restart portainer
```

### Stop Services
```bash
sudo docker compose stop
```

### Start Services
```bash
sudo docker compose start
```

### Remove Services (with data preservation)
```bash
sudo docker compose down
```

### Remove Services (including volumes - DATA LOSS!)
```bash
sudo docker compose down -v
```

### Update to Latest Versions
```bash
sudo docker compose pull
sudo docker compose up -d
```

## Troubleshooting

### Container won't start
```bash
sudo docker compose logs n8n
sudo docker compose logs portainer
```

### Permission issues
```bash
sudo chown -R 1000:1000 n8n-data
sudo chmod -R 755 n8n-data
```

### Check disk space
```bash
df -h
```

### Remove unused Docker resources
```bash
sudo docker system prune -a
```

## Security Recommendations

1. **Change default password** in .env file before starting
2. **Set up SSL/TLS** for production environments
3. **Use a reverse proxy** (nginx, Traefik) for HTTPS
4. **Regular backups** of n8n-data directory
5. **Keep Docker images updated** regularly
6. **Restrict firewall** to only necessary ports
7. **Use strong passwords** for Portainer admin account

## Backup & Restore

### Backup n8n data
```bash
tar -czf n8n-backup-$(date +%Y%m%d).tar.gz n8n-data/
```

### Restore n8n data
```bash
sudo docker compose down
tar -xzf n8n-backup-YYYYMMDD.tar.gz
sudo chown -R 1000:1000 n8n-data
sudo docker compose up -d
```

## Support

For issues or questions:
- n8n Documentation: https://docs.n8n.io
- Portainer Documentation: https://docs.portainer.io
- GitHub Issues: https://github.com/krisnadwiki/n8n-server-install/issues