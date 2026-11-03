# Stage 1: Build the React application
FROM node:20-alpine AS build

WORKDIR /app

# Copy package manifests before source code to leverage Docker layer caching
COPY package*.json ./

# Install dependencies cleanly and deterministically
RUN npm ci

# Copy remaining source code and generate production build
COPY . .
RUN npm run build

# Stage 2: Serve the static build with Nginx
FROM nginx:alpine

# Copy custom Nginx configuration with SPA try_files fallback
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy only the compiled static assets from Stage 1
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
