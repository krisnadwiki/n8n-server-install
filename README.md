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
  - [n8n Workflow Automation - First Time Setup](#n8n-workflow-automation---first-time-setup)
  - [Portainer (Docker Management)](#portainer-docker-management)
- [Maintenance Commands](#maintenance-commands)
- [Troubleshooting](#troubleshooting)
  - [Error 401 Unauthorized or Can't Login](#error-401-unauthorized-or-cant-login)
  - [Container won't start](#container-wont-start)
  - [Permission issues](#permission-issues)
  - [Browser Console Warnings (COOP/HTTPS)](#browser-console-warnings-coophttps)
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
N8N_HOST=192.168.1.100    # ⚠️ CHANGE THIS to your server IP
N8N_PORT=5678
N8N_PROTOCOL=http
NODE_ENV=production

# Timezone (optional)
GENERIC_TIMEZONE=Asia/Jakarta
TZ=Asia/Jakarta
```

**Important:** Replace `N8N_HOST` with your server's IP address (from step 2).

**Note:** Starting from n8n v1.0+, Basic Authentication is deprecated. User authentication is now managed through the web interface during first-time setup.

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

### n8n Workflow Automation - First Time Setup

1. **Open your browser** and navigate to: `http://YOUR-SERVER-IP:5678`

2. **Create Owner Account** - On first access, you will be prompted to create an owner account:
   - **Email:** Enter a valid email address
   - **First Name:** Your first name
   - **Last Name:** Your last name
   - **Password:** Set a strong password (minimum 8 characters)

3. **Complete Setup** - Follow the on-screen prompts to finish the initial setup

4. **Login** - Use the email and password you created to log in

**Important Notes:**
- The owner account is created **only once** during first access
- Basic Auth credentials from .env are **not used** in n8n v1.0+
- If you see a 401 error, the owner may already exist - try logging in or reset (see Troubleshooting)

### Portainer (Docker Management)
- **URL:** `http://YOUR-SERVER-IP:9000`
- **First time:** Create admin user on first access (username + password)

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

### Error 401 Unauthorized or Can't Login

If you see a 401 error or cannot log in, the owner account may have already been created.

**Solution 1: Check existing owner**
```bash
sudo docker exec n8n-server sqlite3 /home/node/.n8n/database.sqlite "SELECT email, firstName, lastName FROM user;"
```
If an email is shown, try logging in with that email.

**Solution 2: Reset and create new owner (⚠️ This will delete all workflows and data)**
```bash
sudo docker compose down
sudo rm -rf n8n-data/database.sqlite*
sudo docker compose up -d
```
Then access `http://YOUR-SERVER-IP:5678` to create a new owner account.

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

### Browser Console Warnings (COOP/HTTPS)

If you see Cross-Origin-Opener-Policy warnings in browser console:
- This is **just a warning**, not an error
- It appears because you're using HTTP instead of HTTPS
- Application will work normally
- For production, consider setting up HTTPS with reverse proxy (nginx/Traefik)

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