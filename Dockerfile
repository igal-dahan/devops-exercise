FROM node:10.15.3-alpine as base

LABEL maintainer "Igal Dahan <igal.dahan@gmail.co>"

RUN apk update \
    && apk add --no-cache \ 
       ca-certificates curl wget lsof \
       vim git less busybox-extras \
       net-tools iftop htop nethogs \
       unzip wget python gcc \
       libc-dev bash make g++

ENV DOCKERIZE_VERSION v0.6.1
RUN wget -q https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && rm dockerize-alpine-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

COPY package.json .

## ---- Dependencies ----
FROM base AS dependencies
# install node packages

## Copy Artifact certificate for login
RUN PYTHON=/usr/bin/python npm --verbose install   

# ---- Release ----
FROM node:10.15.3-alpine AS release

RUN apk update \
    && apk add --no-cache \ 
       curl su-exec\
       vim git less busybox-extras \
       net-tools iftop htop nethogs \
       unzip wget \
       bash 

# INSTALL NODE MODULES
ENV APP_DIR /usr/src/app/users-service
WORKDIR $APP_DIR

RUN chown node:node /usr/src/app/users-service
COPY --from=base /usr/local/bin/dockerize /usr/local/bin/dockerize
COPY --from=dependencies --chown=node /node_modules /usr/src/app/users-service/node_modules 

# COPY users-service CODE
COPY --chown=node . /usr/src/app/users-service
COPY docker-entrypoint.sh /

RUN chmod u+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["npm","start"]
