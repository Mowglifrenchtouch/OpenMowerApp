#!/bin/bash

# Configuration
IMAGE_NAME="ghcr.io/mowglifrenchtouch/openmowerapp"
TAG="lib-updatefull"
BUILDX_CACHE="/tmp/.buildx-cache"
DOCKERFILE="./Dockerfile"

# Crée un builder si nécessaire
docker buildx inspect multiarch-builder >/dev/null 2>&1 || docker buildx create --name multiarch-builder --use

# Authentification GHCR (si nécessaire)
# echo $CR_PAT | docker login ghcr.io -u mowglifrenchtouch --password-stdin

# Supprime le cache précédent (optionnel si tu veux un clean)
# rm -rf $BUILDX_CACHE

# Build + push multi-arch avec cache
docker buildx build \
  --builder multiarch-builder \
  --platform linux/amd64,linux/arm64 \
  --file "$DOCKERFILE" \
  --tag "$IMAGE_NAME:$TAG" \
  --tag "$IMAGE_NAME:dualstick" \
  --push \
  --cache-from type=local,src=$BUILDX_CACHE \
  --cache-to type=local,dest=$BUILDX_CACHE \
  .

echo "✅ Build & push terminé avec succès"
