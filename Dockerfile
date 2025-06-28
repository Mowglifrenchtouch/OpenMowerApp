# ========== Stage 1 : Build Flutter web app ==========
FROM ghcr.io/cirruslabs/flutter:3.22.0 AS build
WORKDIR /app

# Copie le code source dans l'image
COPY . .

# Récupère les dépendances
RUN flutter pub get

# Active le mode web
RUN flutter config --enable-web

# Build l'app Flutter Web en mode release
RUN flutter build web --release --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/

# ========== Stage 2 : Serve with NGINX ==========
FROM nginx:alpine
# Copie les fichiers buildés dans le dossier statique de nginx
COPY --from=build /app/build/web /usr/share/nginx/html
# (Optionnel) Supprime la page par défaut de nginx
RUN rm -f /usr/share/nginx/html/index.html

EXPOSE 80

# Lancer nginx
CMD ["nginx", "-g", "daemon off;"]
