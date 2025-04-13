
FROM node:alpine AS build

LABEL authors="RRHMc"

WORKDIR /usr/src/app

COPY package.json package-lock.json ./

RUN npm cache clean --force && \
    npm install -g npm@11.2.0 && \
    npm install --legacy-peer-deps
ENV NODE_OPTIONS=--openssl-legacy-provider
COPY . .
RUN npm run build

# Stage 2
FROM node:alpine
WORKDIR /usr/src/app
COPY --from=build /usr/src/app /usr/src/app
RUN npm install
EXPOSE 3000
CMD ["npm", "start"]