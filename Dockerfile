FROM node:12.18.2-alpine3.10 as builder
RUN mkdir /app
WORKDIR /app
COPY . .

ARG build_env="prod"
ENV build_env="${build_env}"

RUN yarn install
RUN yarn run build

FROM nginx:1.15-alpine

RUN apk add --no-cache --update bash curl && \
    rm -rf /var/cache/apk/*

ARG app_name=php-frontend
ARG build_version="1.0.2-edge"

ENV REACT_APP_EVALUATION_URL=""

EXPOSE 80

HEALTHCHECK --interval=1m --timeout=3s \
    CMD curl --fail http://127.0.0.1 || exit 1

COPY  --from=builder /app/build /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
