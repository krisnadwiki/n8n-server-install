#!/bin/bash

# n8n Docker Compose Installation Script for Ubuntu Server
# This script installs Docker, Docker Compose, and sets up n8n

set -e

echo "======================================"
echo "n8n Docker Compose Installation"
echo "======================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Update system packages
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install prerequisites
echo "Installing prerequisites..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    echo "Docker installed successfully!"
else
    echo "Docker is already installed."
fi

# Install Docker Compose (standalone version as fallback)
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose standalone..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully!"
else
    echo "Docker Compose is already installed."
fi

# Verify installations
echo ""
echo "Verifying installations..."
docker --version
docker compose version 2>/dev/null || docker-compose --version

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo ""
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "Please edit .env file with your configuration!"
    echo "Important: Change the default password in .env file"
else
    echo ".env file already exists"
fi

# Create n8n-local-files directory
mkdir -p n8n-local-files

# Set proper permissions
chmod 755 n8n-local-files

echo ""
echo "======================================"
echo "Installation completed successfully!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your configuration:"
echo "   nano .env"
echo ""
echo "2. Start n8n:"
echo "   docker compose up -d"
echo "   or"
echo "   docker-compose up -d"
echo ""
echo "3. Check logs:"
echo "   docker compose logs -f n8n"
echo "   or"
echo "   docker-compose logs -f n8n"
echo ""
echo "4. Access n8n at:"
echo "   http://your-server-ip:5678"
echo ""
echo "5. Stop n8n:"
echo "   docker compose down"
echo "   or"
echo "   docker-compose down"
echo ""
