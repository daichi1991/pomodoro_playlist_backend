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

RUN cp -p /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default

# NOTE: ベースイメージの/var/log/nginx/配下のログファイル軍はstdout/stderrへのシンボリックリンクになっている
#       今回はファイルとstdout/stderr両方への出力を行うため、シンボリックリンクを削除する
RUN rm -f /var/log/nginx/*

# NOTE: デフォルトのログローテーション設定を削除しカスタムログローテーション設定を導入する
RUN mkdir -p "/var/log/nginx/rotated"
RUN rm -f /etc/logrotate.d/nginx
COPY .container/proxy/logrotate/* /etc/logrotate.d/
RUN chmod 644 /etc/logrotate.d/*

COPY .container/proxy/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx"]
