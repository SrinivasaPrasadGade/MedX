# Stage 1: Build
FROM ghcr.io/cirruslabs/flutter:3.27.1 AS build

WORKDIR /app
COPY . .

# Download dependencies
RUN flutter pub get

# Build web application
RUN flutter build web --release

# Stage 2: Serve
FROM nginx:alpine

# Copy built assets to Nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
