#!/bin/bash
set -e

WEB_IMAGE="ghcr.io/mowglifrenchtouch/openmowerapp"
TARGET_CONTAINER="mowgli-openmower"
TARGET_PATH="/opt/open_mower_ros/web"

echo "📦 Création du conteneur temporaire..."
docker create --name temp-web $WEB_IMAGE

echo "📁 Extraction du build web..."
docker cp temp-web:/usr/share/nginx/html ./temp-web-build

echo "📤 Copie dans $TARGET_CONTAINER:$TARGET_PATH..."
docker cp ./temp-web-build/. $TARGET_CONTAINER:$TARGET_PATH

echo "🧹 Nettoyage..."
docker rm temp-web
rm -rf ./temp-web-build

echo "✅ Webapp mise à jour avec succès dans $TARGET_CONTAINER"
