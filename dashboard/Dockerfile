FROM node:18-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

# Stage 2: Serve using lightweight node or nginx
# For simplicity in this stack, we'll use Vite's preview mode, 
# but in production, we should copy /dist to NGINX.
EXPOSE 4173

CMD ["npm", "run", "preview", "--", "--host"]
