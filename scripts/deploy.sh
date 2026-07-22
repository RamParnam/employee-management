#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo "Usage: ./deploy.sh <image-name> <container-name>"
    exit 1
fi

IMAGE_NAME="$1"
CONTAINER_NAME="$2"

echo "=============================="
echo "Starting Deployment..."
echo "=============================="

echo "Pulling latest Docker image..."
docker pull "$IMAGE_NAME"

echo "Stopping existing container..."
docker stop "$CONTAINER_NAME" || true

echo "Removing existing container..."
docker rm "$CONTAINER_NAME" || true

echo "Starting new container..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 5000:5000 \
  "$IMAGE_NAME"

echo "Waiting for application to start..."
sleep 10

echo "Checking application health..."

curl --fail http://localhost:5000/health

echo ""
echo "================================="
echo "Deployment Completed Successfully"
echo "================================="
