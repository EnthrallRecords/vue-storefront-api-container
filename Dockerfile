FROM node:10-alpine as build

RUN apk add --no-cache git curl

RUN git clone https://github.com/DivanteLtd/vue-storefront-api.git /opt/vue-storefront-api \
    && cd /opt/vue-storefront-api \
    && yarn install \
    && cp /opt/vue-storefront-api/config/default.json /opt/vue-storefront-api/config/local.json

FROM node:10-alpine

COPY --from=0 /opt/vue-storefront-api /opt/vue-storefront-api

COPY entrypoint.sh /

WORKDIR /opt/vue-storefront-api

ENTRYPOINT "/entrypoint.sh"
