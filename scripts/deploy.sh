#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    echo "Usage: ./deploy.sh <image-name>"
    exit 1
fi

IMAGE_NAME="$1"


echo "Reading active port from Nginx..."

ACTIVE_PORT=$(grep "proxy_pass" /etc/nginx/sites-available/default | grep -oE '[0-9]+' | tail -1)

echo "Current Active Port : $ACTIVE_PORT"

if [ "$ACTIVE_PORT" = "5000" ]; then
    NEW_PORT=5001

    ACTIVE_CONTAINER="employee-management-blue"

    NEW_CONTAINER="employee-management-green"

else
    NEW_PORT=5000

    ACTIVE_CONTAINER="employee-management-green"

    NEW_CONTAINER="employee-management-blue"

fi

echo "New Deployment Port : $NEW_PORT"
echo "Current Container   : $ACTIVE_CONTAINER"
echo "New Container       : $NEW_CONTAINER"

echo "=============================="
echo "Starting Deployment..."
echo "=============================="

echo "Pulling latest Docker image..."
docker pull "$IMAGE_NAME"

echo "Removing previous $NEW_CONTAINER (if exists)..."

docker stop "$NEW_CONTAINER" || true
docker rm "$NEW_CONTAINER" || true


#echo "Stopping existing container..."
#docker stop "$CONTAINER_NAME" || true

#echo "Removing existing container..."
#docker rm "$CONTAINER_NAME" || true

echo "Starting new container..."
docker run -d \
  --name "$NEW_CONTAINER" \
  -p "$NEW_PORT":5000 \
  "$IMAGE_NAME"

echo "Waiting for application to start..."
sleep 10

echo "Checking application health..."

curl --fail http://localhost:"$NEW_PORT"/health

echo ""
echo "================================="
echo "Deployment Completed Successfully"
echo "================================="
