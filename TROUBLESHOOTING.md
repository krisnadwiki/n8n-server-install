# Troubleshooting Guide

Common issues and solutions when running n8n with Docker Compose.

## Installation Issues

### Docker not found after installation

**Problem:** `docker: command not found` after running install.sh

**Solution:**
```bash
# Verify Docker installation
sudo systemctl status docker

# If not running, start it
sudo systemctl start docker

# Enable Docker to start on boot
sudo systemctl enable docker

# Add current user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

### Permission denied errors

**Problem:** `permission denied while trying to connect to the Docker daemon socket`

**Solution:**
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Log out and log back in, or run:
newgrp docker

# Verify you can run docker without sudo
docker ps
```

## Configuration Issues

### .env file not found

**Problem:** Error about missing .env file when starting n8n

**Solution:**
```bash
# Copy the example file
cp .env.example .env

# Edit with your settings
nano .env
```

### Port 5678 already in use

**Problem:** `Bind for 0.0.0.0:5678 failed: port is already allocated`

**Solution:**
```bash
# Check what's using the port
sudo netstat -tlnp | grep 5678

# Option 1: Stop the conflicting service
sudo systemctl stop <service-name>

# Option 2: Change n8n port in docker-compose.yml
# Edit the ports section to use a different port:
# ports:
#   - "8080:5678"
```

## Runtime Issues

### n8n container keeps restarting

**Problem:** Container constantly restarts

**Solution:**
```bash
# Check logs for errors
docker compose logs n8n

# Common causes:
# 1. Invalid environment variables - check .env file
# 2. Volume permission issues
# 3. Memory issues - check available memory

# Check container status
docker compose ps

# Restart with fresh logs
docker compose down
docker compose up
```

### Cannot access n8n web interface

**Problem:** Cannot connect to http://server-ip:5678

**Solution:**
```bash
# 1. Verify n8n is running
docker compose ps

# 2. Check if port is exposed
docker compose port n8n 5678

# 3. Check firewall
sudo ufw status
sudo ufw allow 5678

# 4. Check if listening on correct interface
docker compose logs n8n | grep "Editor is now accessible"

# 5. Try accessing from server itself
curl http://localhost:5678
```

### Webhook URLs not working

**Problem:** Webhooks fail or show incorrect URLs

**Solution:**
```bash
# Edit .env file
nano .env

# Set correct WEBHOOK_URL (must be accessible from outside)
# WEBHOOK_URL=http://your-public-ip:5678/
# or
# WEBHOOK_URL=https://your-domain.com/

# Restart n8n
docker compose restart
```

## Data and Backup Issues

### Lost workflows after restart

**Problem:** All workflows disappeared after container restart

**Solution:**
```bash
# Check if volume still exists
docker volume ls | grep n8n_data

# Verify volume is mounted
docker compose config

# If volume is missing, restore from backup
./n8n-manager.sh restore
```

### Backup fails with volume not found

**Problem:** Backup script can't find the volume

**Solution:**
```bash
# List all volumes
docker volume ls

# Get the correct volume name
docker compose config --volumes

# Manually specify volume name in backup command
VOLUME_NAME=$(docker compose config --volumes | grep n8n_data)
echo $VOLUME_NAME

# If still failing, check docker-compose.yml is in current directory
```

### Out of disk space

**Problem:** No space left on device

**Solution:**
```bash
# Check disk usage
df -h

# Clean up Docker system (removes unused data)
docker system prune -a

# Remove old Docker images
docker image prune -a

# Check Docker volume size
docker system df

# If needed, move Docker data directory
sudo systemctl stop docker
sudo mv /var/lib/docker /new/location/docker
sudo ln -s /new/location/docker /var/lib/docker
sudo systemctl start docker
```

## Update Issues

### Update fails or n8n won't start after update

**Problem:** Error after running update command

**Solution:**
```bash
# Rollback to previous version
docker compose down

# Pull specific version instead of latest
# Edit docker-compose.yml, change:
# image: n8nio/n8n:latest
# to:
# image: n8nio/n8n:0.234.0  # use last working version

docker compose up -d

# Check n8n release notes for breaking changes
# https://github.com/n8n-io/n8n/releases
```

## Performance Issues

### n8n running slowly

**Problem:** Workflows execute slowly or interface is laggy

**Solution:**
```bash
# Check container resources
docker stats n8n

# Check system resources
free -m
top

# Increase container memory (edit docker-compose.yml)
# Add under n8n service:
# deploy:
#   resources:
#     limits:
#       memory: 2G
#     reservations:
#       memory: 1G

# Restart with new settings
docker compose down
docker compose up -d
```

### High CPU usage

**Problem:** Docker using too much CPU

**Solution:**
```bash
# Check which workflows are running
docker compose logs n8n | grep "Workflow"

# Limit CPU usage (edit docker-compose.yml)
# Add under n8n service:
# deploy:
#   resources:
#     limits:
#       cpus: '1.5'

# Restart
docker compose down
docker compose up -d
```

## Security Issues

### Authentication not working

**Problem:** Can access n8n without login

**Solution:**
```bash
# Verify .env settings
cat .env | grep AUTH

# Ensure these are set correctly:
# N8N_BASIC_AUTH_ACTIVE=true
# N8N_BASIC_AUTH_USER=your-username
# N8N_BASIC_AUTH_PASSWORD=your-password

# Restart n8n
docker compose restart
```

### Want to use SSL/HTTPS

**Problem:** Running on HTTP only

**Solution:**
See the "Production Setup with SSL" section in README.md for detailed instructions on setting up a reverse proxy with Nginx and Let's Encrypt.

## Database Issues

### SQLite database corrupted

**Problem:** Error about corrupted database

**Solution:**
```bash
# Stop n8n
docker compose down

# Restore from last backup
./n8n-manager.sh restore

# If no backup available, you may need to start fresh
# WARNING: This deletes all workflows
docker compose down -v
docker compose up -d
```

## Getting More Help

### Enable debug logging

```bash
# Edit docker-compose.yml and add:
# environment:
#   - N8N_LOG_LEVEL=debug

# Restart and check logs
docker compose down
docker compose up -d
docker compose logs -f n8n
```

### Collect diagnostic information

```bash
# System info
uname -a
docker --version
docker compose version

# Container status
docker compose ps
docker compose logs n8n --tail 100

# Resource usage
docker stats n8n --no-stream

# Volume info
docker volume inspect $(docker compose config --volumes | grep n8n_data)
```

### Where to get help

- [n8n Community Forum](https://community.n8n.io/)
- [n8n Documentation](https://docs.n8n.io/)
- [GitHub Issues](https://github.com/n8n-io/n8n/issues)
- Check the [README.md](README.md) for detailed setup instructions
