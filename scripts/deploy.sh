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


echo "Updating Nginx configuration..."

sudo sed -i "s/$ACTIVE_PORT/$NEW_PORT/" /etc/nginx/sites-available/default

echo "Validating Nginx configuration..."

sudo nginx -t

echo "Reloading Nginx..."

sudo systemctl reload nginx

echo "Verifying application through Nginx..."

curl --fail http://localhost/health



echo "Updating deployment state..."

cat <<EOF | sudo tee /opt/employee-management/deployment.state > /dev/null
ACTIVE_CONTAINER=$NEW_CONTAINER
ACTIVE_PORT=$NEW_PORT

PREVIOUS_CONTAINER=$ACTIVE_CONTAINER
PREVIOUS_PORT=$ACTIVE_PORT

IMAGE_NAME=$IMAGE_NAME

DEPLOY_TIME=$(date '+%Y-%m-%d %H:%M:%S')

DEPLOY_STATUS=SUCCESS
EOF

echo "Deployment State File"

sudo cat /opt/employee-management/deployment.state

echo ""
echo "Waiting before cleaning old deployment..."
sleep 120



echo ""
echo "==========================================="
echo "Blue-Green Deployment Completed Successfully"
echo "Active Container : $NEW_CONTAINER"
echo "Active Port      : $NEW_PORT"
echo "==========================================="

echo "Current Active   : $NEW_CONTAINER"
echo "Previous Active       : $ACTIVE_CONTAINER (kept for rollback)"
