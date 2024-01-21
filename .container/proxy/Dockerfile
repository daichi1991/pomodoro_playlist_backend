# TODO: change to enechange base image repository
ARG ARG_BASE_IMAGE_URL="public.ecr.aws/docker/library/"

FROM ${ARG_BASE_IMAGE_URL}nginx:1.25.3

RUN apt-get update -yqq && \
    DEBIAN_FRONTEND=noninteractive apt-get -yqq upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
    apt-utils \
    curl \
    procps \
    less \
    vim \
    jq \
    logrotate \
    locales && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log && \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen ja_JP.UTF-8

RUN apt install -y openssl

ENV LC_ALL=ja_JP.UTF-8

WORKDIR /app
COPY .container/proxy/nginx.conf /app/nginx.conf
COPY .container/proxy/entrypoint.sh /app/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]
