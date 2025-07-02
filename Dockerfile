# ========== Stage 1 : Build Flutter web app ==========
FROM ghcr.io/cirruslabs/flutter:3.22.0 AS build
WORKDIR /app

# Copier uniquement les fichiers de dépendances d'abord pour tirer profit du cache
COPY pubspec.* ./
RUN flutter pub get

# Copier ensuite le reste du projet
COPY . .

# Activer le mode web
RUN flutter config --enable-web

# Compiler l'app Flutter Web
RUN flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/

# ========== Stage 2 : Serve with NGINX ==========
FROM nginx:alpine
LABEL org.opencontainers.image.source=https://github.com/Mowglifrenchtouch/OpenMowerApp

# Copier les fichiers web dans nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Supprimer l’index NGINX par défaut
RUN rm -f /usr/share/nginx/html/index.html

EXPOSE 80

# Démarrer nginx
CMD ["nginx", "-g", "daemon off;"]
