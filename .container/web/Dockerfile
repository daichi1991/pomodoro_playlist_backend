ARG ARG_RUBY_VER="3.1.3"

# ECRのpublic registryを使用したい場合は "public.ecr.aws/LIBRARY_ROOT/" を指定
#   例: Ruby （Docker Library版） "public.ecr.aws/docker/library/"
# See: https://gallery.ecr.aws/?searchTerm=ruby
# TODO: change to enechange base image repository
ARG ARG_BASE_IMAGE_URL="public.ecr.aws/docker/library/"

ARG PLATFORM="linux/x86_64"

# --------------------
# base stage （全ステージで共通且つ（ほぼ）不変の初期設定）
# --------------------
FROM --platform=${PLATFORM} ${ARG_BASE_IMAGE_URL}ruby:${ARG_RUBY_VER}-slim AS base

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
    RUBYGEMS_VERSION="3.3.20" \
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
RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg > /dev/null && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" ${PG_MAJOR_VERSION} > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update -yqq && \
    DEBIAN_FRONTEND=noninteractive apt-get -yqq upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq --no-install-recommends \
    libpq-dev \
    postgresql-client-${PG_MAJOR_VERSION} \
    freetds-dev \
    build-essential \
    tzdata \
    ruby-dev \
    pkg-config \
    libxml2-dev \
    libxslt-dev \
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
RUN bundle config build.nokogiri --use-system-libraries && \
    bundle install && \
    rm -rf /usr/local/bundle/cache

FROM base AS jslib

# --------------------
# compile stage
#
#   bundleをベースにしているのはrails自体がbundle installでインストールされるため
#   Gemfileに修正が入ると自動的にこのステージも再ビルドになるが、Railsの構造上仕方がない
# --------------------
FROM jslib AS compile

# gems from bundle stage
COPY --from=bundle ${APP_ROOT}/vendor/bundle/ ${APP_ROOT}/vendor/bundle/

COPY . ${APP_ROOT}

# MEMO: ビルドまたは実行環境の環境変数から引き渡さされることを想定しています。
#       なお、ARGはFROMをまたげないのでこの位置に記載をしています。
#       環境変数に設定することで引き回し可能ですが、イメージやレイヤーに秘匿情報が残らないよう避けています。
ARG RAILS_MASTER_KEY

# --------------------
# production stage
# --------------------
FROM base AS production

# Create user and set ownership as required
RUN adduser web && \
    chown -R web:web ${APP_ROOT} /etc/profile.d \
        /etc/logrotate.d/ /usr/local/bundle/config

COPY --chown=web . ${APP_ROOT}

# library from jemalloc stage
COPY --chown=web --from=jemalloc /usr/local/lib/libjemalloc.so.2 /usr/local/lib/
ENV LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

# gems from bundle stage
COPY --chown=web --from=bundle ${APP_ROOT}/vendor/bundle/ ${APP_ROOT}/vendor/bundle/

# assets from compile stage
COPY --chown=web --from=compile ${APP_ROOT}/public/ ${APP_ROOT}/public/

USER web

RUN mkdir -p "${APP_ROOT}/log/rotated"
RUN cp ${APP_ROOT}/.container/web/logrotate/* /etc/logrotate.d/ && \
    chmod 644 /etc/logrotate.d/*

# NOTE:
#   tmp/sockets：nginxとのunix domain socket接続用。
#   public：nginxの静的ファイル配信用。メンテイン時にも利用する想定。
VOLUME ${APP_ROOT}/tmp/sockets
VOLUME ${APP_ROOT}/public

RUN chmod 755 ${APP_ROOT}/.container/web/entrypoint.sh

# for creating #{app_root}/tmp/sockets/my_app.sock & #{app_root}/tmp/pids/puma.pid
RUN chmod -R 755 ${APP_ROOT}/tmp

# for binding "unix://#{app_root}/tmp/sockets/my_app.sock"
RUN mkdir -p ${APP_ROOT}/tmp/sockets && \
    touch ${APP_ROOT}/tmp/sockets/my_app.sock && \
    chmod 777 ${APP_ROOT}/tmp/sockets/my_app.sock

# set the path to ${APP_ROOT}/vendor/bundle
RUN bundle config set path ${APP_ROOT}/vendor/bundle

ENTRYPOINT ["/app/.container/web/entrypoint.sh"]

CMD /bin/bash -c "bundle exec pumactl start -F /app/.container/web/pumaconf.rb"
