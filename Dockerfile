### Build esy ###
# Adapted from https://github.com/andreypopp/esy-docker/blob/eae0eb686c15576cdf2c9d05309a2585b0a3e95e/esy-docker.mk

# start from node image so we can install esy from npm

FROM node:10.15-alpine as esy-build

ENV TERM=dumb \
  LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

RUN mkdir /esy
WORKDIR /esy

ENV NPM_CONFIG_PREFIX=/esy
RUN npm install -g --unsafe-perm esy@0.5.6

# now that we have esy installed we need a proper runtime

FROM alpine:3.9 as esy-bin

ENV TERM=dumb \
  LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

WORKDIR /

COPY --from=esy-build /esy /esy

RUN apk add --no-cache \
  ca-certificates wget \
  bash curl perl-utils \
  git patch gcc g++ musl-dev make m4

RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk
RUN apk add --no-cache glibc-2.28-r0.apk

ENV PATH=/esy/bin:$PATH


### Development environment ###
FROM esy-bin as development

# Niceties
RUN apk add --no-cache fish vim

# Needed for @esy-ocaml/libffi@3.2.10
RUN apk add --no-cache texinfo
# Needed for @opam/tls
RUN apk add --no-cache gmp-dev
# Need for @opam/caqti-driver-mariadb
RUN apk add --no-cache mariadb-dev

RUN mkdir /app
WORKDIR /app

ENTRYPOINT ["tail", "-f", "/dev/null"]