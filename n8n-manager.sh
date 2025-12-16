#!/bin/bash

# n8n Management Script
# Simplifies common n8n operations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "ℹ $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Check if .env file exists
check_env() {
    if [ ! -f .env ]; then
        print_warning ".env file not found!"
        print_info "Creating from .env.example..."
        cp .env.example .env
        print_warning "Please edit .env file with your configuration before starting n8n!"
        exit 1
    fi
}

# Show usage
show_usage() {
    echo "n8n Manager - Manage your n8n installation"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start       Start n8n"
    echo "  stop        Stop n8n"
    echo "  restart     Restart n8n"
    echo "  status      Show n8n status"
    echo "  logs        Show n8n logs (press Ctrl+C to exit)"
    echo "  update      Update n8n to latest version"
    echo "  backup      Create a backup of n8n data"
    echo "  restore     Restore from a backup"
    echo "  reset       Reset n8n (WARNING: deletes all data)"
    echo "  help        Show this help message"
    echo ""
}

# Start n8n
start_n8n() {
    check_docker
    check_env
    print_info "Starting n8n..."
    docker compose up -d
    print_success "n8n started successfully!"
    print_info "Access n8n at: http://$(hostname -I | awk '{print $1}'):5678"
}

# Stop n8n
stop_n8n() {
    check_docker
    print_info "Stopping n8n..."
    docker compose down
    print_success "n8n stopped successfully!"
}

# Restart n8n
restart_n8n() {
    check_docker
    print_info "Restarting n8n..."
    docker compose restart
    print_success "n8n restarted successfully!"
}

# Show status
show_status() {
    check_docker
    print_info "n8n Status:"
    docker compose ps
}

# Show logs
show_logs() {
    check_docker
    print_info "Showing n8n logs (press Ctrl+C to exit)..."
    docker compose logs -f n8n
}

# Update n8n
update_n8n() {
    check_docker
    print_info "Updating n8n to latest version..."
    docker compose pull
    print_success "Latest image pulled!"
    print_info "Restarting n8n with new version..."
    docker compose up -d
    print_success "n8n updated successfully!"
}

# Backup n8n data
backup_n8n() {
    check_docker
    BACKUP_DIR="backups"
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/n8n-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    print_info "Creating backup..."
    docker run --rm \
        -v "$(basename $SCRIPT_DIR)_n8n_data:/data" \
        -v "$SCRIPT_DIR/$BACKUP_DIR:/backup" \
        alpine tar czf "/backup/$(basename $BACKUP_FILE)" -C /data .
    
    print_success "Backup created: $BACKUP_FILE"
}

# Restore from backup
restore_n8n() {
    check_docker
    BACKUP_DIR="backups"
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR)" ]; then
        print_error "No backups found in $BACKUP_DIR"
        exit 1
    fi
    
    print_info "Available backups:"
    ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null || { print_error "No backup files found!"; exit 1; }
    echo ""
    read -p "Enter backup filename to restore: " BACKUP_FILE
    
    if [ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
        print_error "Backup file not found: $BACKUP_DIR/$BACKUP_FILE"
        exit 1
    fi
    
    print_warning "This will replace all current n8n data!"
    read -p "Are you sure? (yes/no): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        print_info "Restore cancelled."
        exit 0
    fi
    
    print_info "Stopping n8n..."
    docker compose down
    
    print_info "Restoring from backup..."
    docker run --rm \
        -v "$(basename $SCRIPT_DIR)_n8n_data:/data" \
        -v "$SCRIPT_DIR/$BACKUP_DIR:/backup" \
        alpine sh -c "rm -rf /data/* && tar xzf /backup/$BACKUP_FILE -C /data"
    
    print_success "Backup restored!"
    print_info "Starting n8n..."
    docker compose up -d
    print_success "n8n started with restored data!"
}

# Reset n8n
reset_n8n() {
    check_docker
    print_warning "WARNING: This will delete all n8n data including workflows and credentials!"
    read -p "Are you sure you want to reset n8n? (yes/no): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        print_info "Reset cancelled."
        exit 0
    fi
    
    print_info "Stopping n8n and removing volumes..."
    docker compose down -v
    print_success "n8n reset complete!"
    print_info "Start n8n with: $0 start"
}

# Main script logic
case "${1:-}" in
    start)
        start_n8n
        ;;
    stop)
        stop_n8n
        ;;
    restart)
        restart_n8n
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    update)
        update_n8n
        ;;
    backup)
        backup_n8n
        ;;
    restore)
        restore_n8n
        ;;
    reset)
        reset_n8n
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
