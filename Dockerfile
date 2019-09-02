FROM node:10-alpine as build

ARG VERSION=1.8.1

RUN apk add --no-cache git python build-base

RUN wget -qO- https://github.com/DivanteLtd/vue-storefront-api/archive/v${VERSION}.tar.gz | tar -xvz \
    && mv vue-storefront-api-${VERSION} /opt/vue-storefront-api \
    && cd /opt/vue-storefront-api \
    && yarn install \
    && cp /opt/vue-storefront-api/config/default.json /opt/vue-storefront-api/config/local.json \
    && yarn build

FROM node:10-alpine

RUN apk add --no-cache imagemagick

COPY --from=0 /opt/vue-storefront-api /opt/vue-storefront-api

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront-api

ENTRYPOINT "/entrypoint.sh"
