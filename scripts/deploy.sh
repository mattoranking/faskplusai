#!/bin/bash

# Manual deployment script (backup for CI/CD)

set -e

ENVIRONMENT=${1:-staging}

echo "🚀 Deploying to $ENVIRONMENT..."

# Pull latest code
echo "📥 Pulling latest code..."
git pull origin $(git branch --show-current)

# Build and deploy
echo "🏗️  Building and deploying containers..."
if [ "$ENVIRONMENT" == "production" ]; then
    docker-compose -f docker-compose.prod.yml build
    docker-compose -f docker-compose.prod.yml up -d --force-recreate
else
    docker-compose -f docker-compose.staging.yml build
    docker-compose -f docker-compose.staging.yml up -d --force-recreate
fi

# Clean up
echo "🧹 Cleaning up old images..."
docker system prune -af

# Show status
echo "📊 Container status:"
if [ "$ENVIRONMENT" == "production" ]; then
    docker-compose -f docker-compose.prod.yml ps
else
    docker-compose -f docker-compose.staging.yml ps
fi

echo "✅ Deployment complete!"
