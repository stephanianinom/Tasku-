# Multi-stage build para Angular
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY angular.json tsconfig*.json ./
RUN npm install
COPY src ./src
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/tasku-frontend/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
