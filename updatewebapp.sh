#!/bin/bash
set -e

IMAGE="ghcr.io/mowglifrenchtouch/openmowerapp:latest"
TARGET_CONTAINER="mowgli-openmower"
TARGET_PATH="/opt/open_mower_ros/web"
TMP_BUILD_DIR="./temp-web-build"

# 1. Détection de l'architecture locale
ARCH=$(uname -m)

case "$ARCH" in
  x86_64)
    PLATFORM="linux/amd64"
    ;;
  aarch64 | arm64)
    PLATFORM="linux/arm64"
    ;;
  *)
    echo "❌ Architecture non supportée : $ARCH"
    exit 1
    ;;
esac

echo " Détecté : $ARCH → plateforme Docker : $PLATFORM"

# 2. Création conteneur temporaire avec la bonne plateforme
echo " Création du conteneur temporaire avec $PLATFORM..."
docker create --platform $PLATFORM --name temp-web $IMAGE

# 3. Copie des fichiers web depuis l'image
echo " Extraction des fichiers du conteneur temporaire..."
docker cp temp-web:/usr/share/nginx/html $TMP_BUILD_DIR

# 4. Nettoyage préalable dans le conteneur cible
echo " Suppression de l'ancien contenu dans $TARGET_PATH du conteneur $TARGET_CONTAINER..."
docker exec $TARGET_CONTAINER bash -c "mkdir -p $TARGET_PATH && rm -rf $TARGET_PATH/*"

# 5. Injection des nouveaux fichiers
echo " Copie dans $TARGET_CONTAINER:$TARGET_PATH..."
docker cp $TMP_BUILD_DIR/. $TARGET_CONTAINER:$TARGET_PATH

# 6. Nettoyage
echo "🧹 Nettoyage temporaire..."
docker rm temp-web > /dev/null
rm -rf $TMP_BUILD_DIR

# 7. Redémarrage du conteneur
echo "🔄 Redémarrage du conteneur $TARGET_CONTAINER..."
docker restart $TARGET_CONTAINER

echo "✅ Webapp mise à jour et conteneur redémarré avec succès 🎉"
