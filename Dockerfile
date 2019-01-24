FROM node:10-alpine as build

ARG VERSION=v1.7.0

RUN apk add --no-cache git python build-base

RUN mkdir -p /opt/vue-storefront-api \
    && wget -qO- https://github.com/DivanteLtd/vue-storefront-api/archive/${VERSION}.tar.gz | tar -xvz -C /opt/vue-storefront-api \
    && cd /opt/vue-storefront-api \
    && yarn install \
    && cp /opt/vue-storefront-api/config/default.json /opt/vue-storefront-api/config/local.json \
    && yarn build

FROM node:10-alpine

COPY --from=0 /opt/vue-storefront-api /opt/vue-storefront-api

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront-api

ENTRYPOINT "/entrypoint.sh"
