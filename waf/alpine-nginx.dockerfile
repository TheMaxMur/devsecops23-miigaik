ARG ALPINE_VERSION=3.14.9

FROM alpine:${ALPINE_VERSION}

ARG OPENRESTY_VERSION=1.21.4.1
ARG CORERULESET_VERSION=3.3.4
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

RUN cd /usr/local;\
    wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v${CORERULESET_VERSION}.tar.gz; \
    tar -xzvf v${CORERULESET_VERSION}.tar.gz; \
    mv coreruleset-${CORERULESET_VERSION}/ /usr/local; \
    cd /usr/local/coreruleset-${CORERULESET_VERSION}/; \
    cp crs-setup.conf.example crs-setup.conf; \
    cd /usr/local/coreruleset-${CORERULESET_VERSION}/rules; \
    mv REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf; \
    mv RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

RUN apk update && \
    apk add --no-cache pv ca-certificates clamav clamav-libunrar perl && \
    apk add --upgrade apk-tools libcurl openssl busybox && \
    rm -rf /var/cache/apk/* && \ 
    mkdir -p /usr/local/clamav/rules

COPY ./modsec/coreruleset/crs.setup.conf /usr/local/coreruleset-${CORERULESET_VERSION}/crs.setup.conf

COPY ./modsec/modsecurity.conf /opt/ModSecurity/modsecurity.conf 
COPY ./modsec/main.conf /opt/ModSecurity/main.conf

COPY ./modsec/ClamAV/modsec_clamav.conf /usr/local/clamav/rules/modsec_clamav.conf
COPY ./modsec/ClamAV/modsec_clamav.pl /usr/local/clamav/rules/modsec_clamav.pl

COPY ./nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

COPY ./nginx/conf.d /usr/local/openresty/nginx/conf/conf.d

RUN chown -R 1001:1001 /opt; \
    chown -R 1001:1001 /usr/local/ ;\
    chown -R 1001:1001 /var/run/openresty/;\
    chmod +x /usr/local/clamav/rules/modsec_clamav.pl

RUN chmod -R 700 /bin;\
    chmod -R 700 /usr/bin;\
    chmod 701 /usr/bin/openresty

USER 1001:1001

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]