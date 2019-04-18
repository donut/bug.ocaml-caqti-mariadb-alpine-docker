### Build esy ###
# Adapted from https://github.com/andreypopp/esy-docker/blob/eae0eb686c15576cdf2c9d05309a2585b0a3e95e/esy-docker.mk

# start from node image so we can install esy from npm

# FROM node:10.15-alpine as esy-build

# ENV TERM=dumb \
#   LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

# RUN mkdir /esy
# WORKDIR /esy

# ENV NPM_CONFIG_PREFIX=/esy
# RUN npm install -g --unsafe-perm esy@0.5.6

# now that we have esy installed we need a proper runtime

FROM ubuntu:bionic as esy-bin

ENV TERM=dumb \
  LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

WORKDIR /

RUN apt-get update && apt-get install --assume-yes \
  build-essential \
  ca-certificates wget \
  curl unzip \
  git gcc g++ musl-dev make automake autoconf perl m4 libtool \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
      | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update  \
  && apt-get install --assume-yes yarn \
  && rm -rf /var/lib/apt/lists/*

ENV TERM=dumb \
  LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib

RUN mkdir /esy
WORKDIR /esy

ENV NPM_CONFIG_PREFIX=/esy
RUN yarn global add esy@0.5.6

ENV PATH=/esy/bin:$PATH


### Development environment ###
FROM esy-bin as development

RUN apt-get update && apt-get install --assume-yes \
  # Niceties
  fish vim \
  # Needed for @opam/caqti-driver-mariadb
  libmariadb-dev \
  # Needed for @esy-ocaml/libffi@3.2.10
  texinfo \
  # Clean up
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /app
WORKDIR /app

ENTRYPOINT ["tail", "-f", "/dev/null"]