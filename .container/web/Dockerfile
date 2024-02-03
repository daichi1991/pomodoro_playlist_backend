ARG ARG_RUBY_VER="3.1.3"

# ECRのpublic registryを使用したい場合は "public.ecr.aws/LIBRARY_ROOT/" を指定
#   例: Ruby （Docker Library版） "public.ecr.aws/docker/library/"
# See: https://gallery.ecr.aws/?searchTerm=ruby
# TODO: change to enechange base image repository
ARG ARG_BASE_IMAGE_URL="public.ecr.aws/docker/library/"

# --------------------
# base stage （全ステージで共通且つ（ほぼ）不変の初期設定）
# --------------------
FROM ${ARG_BASE_IMAGE_URL}ruby:${ARG_RUBY_VER}-slim-bookworm AS base

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# TODO: localteの設定はベースイメージでやって良いかも
#       ここでインストールしている奴らはベースでインストールしたほうが良さそう
RUN apt-get update -yqq && \
    DEBIAN_FRONTEND=noninteractive apt-get -yqq upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
    curl \
    less \
    vim \
    jq \
    gnupg2 \
    logrotate \
    lsb-release \
    locales && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log && \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen ja_JP.UTF-8

# FIXME: add RAILS_MASTER_KEY env var
#        RAILS_ENVとRAILS_MASTER_KEYはビルド環境からもらうほうが良さげ
#        LANGとLC_ALLはベースイメージに持っていくのが良さげ
ENV APP_ROOT=/app \
    LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RUBY_VERSION=${ARG_RUBY_VER} \
    RUBYGEMS_VERSION="3.3.24" \
    PG_MAJOR_VERSION="12" \
    JEMALLOC_VERSION="5.3.0" \
    RAILS_ENV=production

WORKDIR ${APP_ROOT}

# NOTE: https://wiki.postgresql.org/wiki/Apt
#       pg gemでヘッダーを利用するため install postgresql client
#       pg gemのコンパイルだけであれば実際にRDSで使用しているpostgresqlのバージョンと一致している必要はない
#       ランタイムで必要なのでこの時点でインストールする
# See: https://nokogiri.org/tutorials/installing_nokogiri.html#installing-using-standard-system-libraries
# TODO: curl, lessあたりはベースイメージで入れて良さそう
#       各パッケージがなんのためにインストールされているのかはコメントしても良いかも
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg > /dev/null && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" ${PG_MAJOR_VERSION} > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update -yqq && \
    DEBIAN_FRONTEND=noninteractive apt-get -yqq upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
    libpq-dev \
    postgresql-client-${PG_MAJOR_VERSION} \
    build-essential \
    tzdata \
    ruby-dev \
    pkg-config \
    libxml2-dev \
    libxslt-dev \
    zlib1g-dev \
    liblzma-dev \
    patch \
    shared-mime-info && \
    apt-get clean && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# NOTE: Ruby Gemsの更新
# https://blog.rubygems.org/
RUN gem update --system ${RUBYGEMS_VERSION}

RUN bundle config set --local without 'test development' && \
    bundle config set path ${APP_ROOT}/vendor/bundle

RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# --------------------
# jemalloc stage （jemallocのセットアップ）
#
#   puma x Railsではメモリが開放されないで累積していく傾向があり、Cレベルのメモリ管理にjemallocを使うことで緩和する
#   （比較的一般的な解法のひとつです）
# --------------------
FROM base AS jemalloc

RUN curl -L -o jemalloc-${JEMALLOC_VERSION}.tar.bz https://github.com/jemalloc/jemalloc/releases/download/${JEMALLOC_VERSION}/jemalloc-${JEMALLOC_VERSION}.tar.bz2 && \
    tar -xjf jemalloc-${JEMALLOC_VERSION}.tar.bz && \
    cd jemalloc-${JEMALLOC_VERSION} && \
    ./configure && \
    make && \
    make install

# --------------------
# bundle stage
# --------------------
FROM base AS bundle

# bundle installの際、Dockerのビルドキャッシュを活用するためGemfile系のみをコピーする
# これによりGemfile系ファイルに変更があった場合のみbundle installが実行される
COPY Gemfile* ${APP_ROOT}/

# See: https://github.com/rubygems/rubygems/issues/3225#issuecomment-822052404
# See: https://nokogiri.org/tutorials/installing_nokogiri.html#installing-using-standard-system-libraries
# RUN bundle config build.nokogiri --use-system-libraries && \
RUN gem install nokogiri --platform=ruby && \
    bundle config --local build.sassc --disable-march-tune-native && \
    bundle install && \
    rm -rf /usr/local/bundle/cache

# --------------------
# production stage
# --------------------
FROM base AS production

COPY . ${APP_ROOT}

# library from jemalloc stage
COPY --from=jemalloc /usr/local/lib/libjemalloc.so.2 /usr/local/lib/
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

# gems from bundle stage
COPY --from=bundle ${APP_ROOT}/vendor/bundle/ ${APP_ROOT}/vendor/bundle/

RUN mkdir -p "${APP_ROOT}/tmp/pids"

RUN mkdir -p "${APP_ROOT}/log/rotated"
RUN cp ${APP_ROOT}/.container/web/logrotate/* /etc/logrotate.d/ && \
    chmod 644 /etc/logrotate.d/*

# NOTE:
#   tmp/sockets：nginxとのunix domain socket接続用。
#   public：nginxの静的ファイル配信用。メンテイン時にも利用する想定。
VOLUME ${APP_ROOT}/tmp/sockets
VOLUME ${APP_ROOT}/public

RUN chmod 755 ${APP_ROOT}/.container/web/entrypoint.sh
ENTRYPOINT ["/bin/bash", "-c", "${APP_ROOT}/.container/web/entrypoint.sh"]
