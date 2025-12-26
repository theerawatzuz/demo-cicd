#!/bin/bash

# Gold Price API Deployment Script
# This script deploys the application using Docker on Ubuntu server

set -e

echo "🚀 Starting deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/opt/gold-price-api"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

# Pull latest code
echo -e "${YELLOW}📥 Pulling latest code...${NC}"
git pull origin main

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker-compose down

# Remove old images
echo -e "${YELLOW}🗑️  Removing old images...${NC}"
docker image prune -f

# Build new image
echo -e "${YELLOW}🔨 Building new Docker image...${NC}"
docker-compose build --no-cache

# Start containers
echo -e "${YELLOW}▶️  Starting containers...${NC}"
docker-compose up -d

# Wait for container to be healthy
echo -e "${YELLOW}⏳ Waiting for container to be healthy...${NC}"
sleep 10

# Check container status
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo -e "${GREEN}🪙 Gold Price API is running${NC}"
    docker-compose ps
else
    echo -e "${RED}❌ Deployment failed. Check logs:${NC}"
    docker-compose logs --tail=50
    exit 1
fi

# Show logs
echo -e "${YELLOW}📋 Recent logs:${NC}"
docker-compose logs --tail=20

echo -e "${GREEN}✨ Deployment completed!${NC}"
