ARG ALPINE_VERSION=3.14.9
ARG OPENRESTY_VERSION=1.21.4.1


FROM alpine:${ALPINE_VERSION}

RUN apk update 
RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        ca-certificates \
        coreutils \        
        curl-dev \
        g++ \
        gcc \
        geoip-dev \
        git \
        libc-dev \       
        libmaxminddb-dev \
        libstdc++ \
        libtool \
        libxml2-dev \
        linux-headers \
        lmdb-dev \
        make \
        openssl \
        openssl-dev \
        patch \
        pkgconfig \
        pcre-dev \
        pcre2-dev \
        yajl-dev \
        zlib-dev
WORKDIR /opt

RUN git clone https://github.com/SpiderLabs/ModSecurity; \
    cd ModSecurity/ ;\
    git checkout -b v3/master origin/v3/master; \
    ./build.sh; \
    git submodule init;\
    git submodule update ;\
    ./configure; \
    make;\
    make install

RUN cd /opt;  \
    wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz;  \
    git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git; \
    tar xvf openresty-${OPENRESTY_VERSION}.tar.gz;\
    cd openresty-${OPENRESTY_VERSION};\
    ./configure --with-compat --add-dynamic-module=/opt/ModSecurity-nginx/;\
    ln -s /usr/bin/make /usr/bin/gmake;\
    gmake; \
    gmake install;\
    ln -s /usr/local/openresty/bin/openresty /usr/bin/openresty;\
    mkdir -p /var/run/openresty 

CMD ["openresty", "-g", "daemon off;"]