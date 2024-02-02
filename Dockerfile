FROM ubuntu:20.04
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl wget && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends bzip2 unzip xz-utils && rm -rf /var/lib/apt/lists/*

RUN { echo '#!/bin/sh'; echo 'set -e'; echo; echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home

RUN set -x && apt-get update && apt-get install -y openjdk-8-jre-headless && \
    rm -rf /var/lib/apt/lists/* 

RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure &&\
    apt-get update && apt-get install -y libc6-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV JRUBY_VERSION=9.1.7.0
ENV JRUBY_SHA256=95ac7d2316fb7698039267265716dd2159fa5b49f0e0dc6e469c80ad59072926

RUN mkdir /opt/jruby && curl -fSL https://s3.amazonaws.com/jruby.org/downloads/${JRUBY_VERSION}/jruby-bin-${JRUBY_VERSION}.tar.gz -o /tmp/jruby.tar.gz && echo "$JRUBY_SHA256 /tmp/jruby.tar.gz" | sha256sum -c - && tar -zx --strip-components=1 -f /tmp/jruby.tar.gz -C /opt/jruby && rm /tmp/jruby.tar.gz && update-alternatives --install /usr/local/bin/ruby ruby /opt/jruby/bin/jruby 1

ENV PATH=/opt/jruby/bin:$PATH
RUN mkdir -p /opt/jruby/etc && { echo 'install: --no-document'; echo 'update: --no-document'; } >> /opt/jruby/etc/gemrc
RUN gem install bundler -v 1.17.3
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=/usr/local/bundle BUNDLE_BIN=/usr/local/bundle/bin BUNDLE_SILENCE_ROOT_WARNING=1 BUNDLE_APP_CONFIG=/usr/local/bundle
ENV PATH=/usr/local/bundle/bin:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" && chmod 777 "$GEM_HOME" "$BUNDLE_BIN"

ENV EMBULK_VERSION 0.8.15
RUN wget --no-check-certificate https://dl.embulk.org/embulk-${EMBULK_VERSION}.jar -O /usr/local/bin/embulk
RUN chmod +x /usr/local/bin/embulk
ENV PATH /usr/local/bin/embulk:$PATH

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash &&\
    export NVM_DIR="$HOME/.nvm" &&\
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" &&\
    nvm --version && nvm install v20.9.0 && nvm use v20.9.0 && nvm alias default v20.9.0
