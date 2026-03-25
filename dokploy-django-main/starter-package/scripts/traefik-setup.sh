#!/bin/bash
# =================================================================
# TRAEFIK SETUP SCRIPT FOR DOKPLOY
# =================================================================
# This script sets up Traefik container for Dokploy deployments
# Run this ONCE on your VPS after installing Dokploy
# =================================================================
# Usage:
#   chmod +x traefik-setup.sh
#   sudo ./traefik-setup.sh
# =================================================================

set -e  # Exit on error

echo "=========================================="
echo "🚀 Traefik Setup for Dokploy"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (sudo)${NC}"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Checking existing Traefik containers...${NC}"

# Check if Traefik is already running
if docker ps -a | grep -q dokploy-traefik; then
    echo -e "${YELLOW}⚠️  Traefik container already exists${NC}"
    read -p "Do you want to remove and recreate it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🗑️  Removing existing Traefik container...${NC}"
        docker stop dokploy-traefik 2>/dev/null || true
        docker rm dokploy-traefik 2>/dev/null || true
    else
        echo -e "${GREEN}✅ Keeping existing container${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${YELLOW}🔍 Checking port availability...${NC}"

# Check if ports 8082 and 8445 are available
if netstat -tuln | grep -q ':8082 '; then
    echo -e "${RED}❌ Port 8082 is already in use${NC}"
    echo "Please free up port 8082 or modify the script to use different ports"
    exit 1
fi

if netstat -tuln | grep -q ':8445 '; then
    echo -e "${RED}❌ Port 8445 is already in use${NC}"
    echo "Please free up port 8445 or modify the script to use different ports"
    exit 1
fi

echo -e "${GREEN}✅ Ports 8082 and 8445 are available${NC}"
echo ""

# Check if dokploy-network exists
echo -e "${YELLOW}🔍 Checking dokploy-network...${NC}"
if ! docker network ls | grep -q dokploy-network; then
    echo -e "${RED}❌ dokploy-network does not exist${NC}"
    echo "Please install Dokploy first"
    exit 1
fi

echo -e "${GREEN}✅ dokploy-network found${NC}"
echo ""

# Pull Traefik image
echo -e "${YELLOW}📥 Pulling Traefik v3.5.0 image...${NC}"
docker pull traefik:v3.5.0

echo ""
echo -e "${YELLOW}🚀 Creating Traefik container...${NC}"

# Create Traefik container
docker run -d \
    --name dokploy-traefik \
    --restart always \
    -v /etc/dokploy/traefik/traefik.yml:/etc/traefik/traefik.yml \
    -v /etc/dokploy/traefik/dynamic:/etc/dokploy/traefik/dynamic \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 8082:80/tcp \
    -p 8445:443/tcp \
    -p 8445:443/udp \
    traefik:v3.5.0

echo -e "${GREEN}✅ Traefik container created${NC}"
echo ""

# Connect to dokploy-network
echo -e "${YELLOW}🔗 Connecting Traefik to dokploy-network...${NC}"
docker network connect dokploy-network dokploy-traefik

echo -e "${GREEN}✅ Connected to dokploy-network${NC}"
echo ""

# Wait for Traefik to start
echo -e "${YELLOW}⏳ Waiting for Traefik to start...${NC}"
sleep 5

# Check if Traefik is running
if docker ps | grep -q dokploy-traefik; then
    echo -e "${GREEN}✅ Traefik is running!${NC}"
else
    echo -e "${RED}❌ Traefik failed to start${NC}"
    echo "Check logs with: docker logs dokploy-traefik"
    exit 1
fi

echo ""
echo "=========================================="
echo -e "${GREEN}🎉 Traefik Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "📊 Container Status:"
docker ps --filter name=dokploy-traefik --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "📝 Next Steps:"
echo "1. Configure your apps in Dokploy with domain settings"
echo "2. Set up nginx to proxy to port 8082"
echo "3. Test your deployments"
echo ""
echo "🔍 Useful Commands:"
echo "  View logs:    docker logs dokploy-traefik"
echo "  Restart:      docker restart dokploy-traefik"
echo "  Check routes: docker exec dokploy-traefik wget -O- http://localhost:8080/api/http/routers 2>/dev/null"
echo ""
echo -e "${GREEN}✅ Setup successful!${NC}"
