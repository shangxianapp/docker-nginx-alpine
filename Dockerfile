ARG FROM_IMAGE_BASE="alpine"
ARG FROM_IMAGE_TAG="3.9"

FROM ${FROM_IMAGE_BASE}:${FROM_IMAGE_TAG}

LABEL maintainer="Wang Shaobo <fireshooter@163.com>, xuexb <fe.xiaowu@gmail.com>, yugasun <yuga.sun.bj@gmail.com>"
LABEL org.opencontainers.image.source https://github.com/shangxianapp/docker-nginx-alpine

ENV LANG en_US.UTF-8
ENV TZ Asia/Shanghai
ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.1

ARG NGINX_VERSION=1.14.2
ARG NGX_DEVEL_KIT_VERSION=0.3.1
ARG OPENRESTY_LUAJIT_VERSION=2.1-20220411
ARG LUA_NGINX_MODULE_VERSION=0.10.21
ARG ECHO_NGINX_MODULE_VERSION=0.62
ARG HEADERS_MORE_NGINX_MODULE=0.33
ARG HTTP_CONCAT_NGINX_MODULE_VERSION=1.2.2
ARG LUA_RESTY_CORE_VERSION=0.1.23
ARG LUA_RESTY_LRUCACHE_VERSION=0.13
ARG LUAROCKS_VERSION=3.8.0
ARG NGINX_CONFIG_OPTIONS="\
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-ipv6 \
    --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" \
    --add-module=/tmp/nginx-brotli \
    --add-module=/tmp/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
    --add-module=/tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} \
    --add-module=/tmp/echo-nginx-module-${ECHO_NGINX_MODULE_VERSION} \
    --add-module=/tmp/nginx-http-concat-${HTTP_CONCAT_NGINX_MODULE_VERSION} \
    --add-module=/tmp/headers-more-nginx-module-${HEADERS_MORE_NGINX_MODULE} \
    "

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && addgroup -S nginx \
    && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx -u 1000 nginx \
    && apk update \
    && apk add --no-cache --virtual .build-deps \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        git \
        gnupg \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        perl-dev \
        luajit-dev \
    && apk add --no-cache \
        build-base \
        linux-headers \
        libintl \
        musl \
        wget \
        make \
        curl \
        unzip \
        outils-md5 \
    && apk add --no-cache libwebp-tools \
    && apk add --no-cache tzdata \
    && curl -fSL https://github.com/openresty/luajit2/archive/v${OPENRESTY_LUAJIT_VERSION}.tar.gz -o /tmp/openresty-luajit.tar.gz \
    && tar -xvf /tmp/openresty-luajit.tar.gz -C /tmp \
    && cd /tmp/luajit2-${OPENRESTY_LUAJIT_VERSION} \
    && make && make install \
    && rm -f /tmp/openresty-luajit.tar.gz \
    # && rm -rf /tmp/luajit2-${OPENRESTY_LUAJIT_VERSION} \
    && curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz -o /tmp/ndk.tar.gz \
    && curl -fSL https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_MODULE_VERSION}.tar.gz -o /tmp/lua-nginx.tar.gz \
    && curl -fSL https://github.com/alibaba/nginx-http-concat/archive/${HTTP_CONCAT_NGINX_MODULE_VERSION}.tar.gz -o /tmp/nginx-http-concat.tar.gz \
    && curl -fSL https://github.com/openresty/echo-nginx-module/archive/v${ECHO_NGINX_MODULE_VERSION}.tar.gz -o /tmp/echo-nginx.tar.gz \
    && curl -fSL https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_NGINX_MODULE}.tar.gz -o /tmp/headers-more-nginx-module.tar.gz \
    && curl -fSL https://github.com/openresty/lua-resty-core/archive/v${LUA_RESTY_CORE_VERSION}.tar.gz -o /tmp/lua-resty-core.tar.gz \
    && curl -fSL https://github.com/openresty/lua-resty-lrucache/archive/v${LUA_RESTY_LRUCACHE_VERSION}.tar.gz -o /tmp/lua-resty-lrucache.tar.gz \
    && tar -xvf /tmp/ndk.tar.gz -C /tmp \
    && tar -xvf /tmp/lua-nginx.tar.gz -C /tmp \
    && tar -xvf /tmp/echo-nginx.tar.gz -C /tmp \
    && tar -xvf /tmp/headers-more-nginx-module.tar.gz -C /tmp \
    && tar -xvf /tmp/nginx-http-concat.tar.gz -C /tmp \
    && tar -xvf /tmp/lua-resty-core.tar.gz -C /tmp \
    && tar -xvf /tmp/lua-resty-lrucache.tar.gz -C /tmp \
    && curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz \
    && git clone --no-tags --depth 1 --recursive https://github.com/google/ngx_brotli.git /tmp/nginx-brotli \
    && mkdir -p /usr/src \
    && tar -zxC /usr/src -f nginx.tar.gz \
    && rm nginx.tar.gz \
    && cd /usr/src/nginx-${NGINX_VERSION} \
    && ./configure ${NGINX_CONFIG_OPTIONS} \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && sed -i "s/-Werror//g" objs/Makefile \
    && make install \
    && rm -rf /etc/nginx/html/ \
    && mkdir /etc/nginx/conf.d/ \
    && mkdir -p /usr/share/nginx/html/ \
    && install -m644 html/index.html /usr/share/nginx/html/ \
    && install -m644 html/50x.html /usr/share/nginx/html/ \
    # && install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
    # && install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
    # && install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
    # && install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
    # && install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
    && ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
    && cd /tmp/lua-resty-core-${LUA_RESTY_CORE_VERSION} \
    && make install \
    && cd /tmp/lua-resty-lrucache-${LUA_RESTY_LRUCACHE_VERSION} \
    && make install \
    && strip /usr/sbin/nginx* \
    && strip /usr/lib/nginx/modules/*.so \
    && rm -rf /tmp/headers-more-nginx-module.tar.gz \
    && rm -rf /tmp/nginx-http-concat.tar.gz \
    && rm -rf /usr/src/nginx-${NGINX_VERSION} \
    && rm -f /tmp/ndk.tar.gz \
    && rm -f /tmp/echo-nginx.tar.gz \
    && rm -f /tmp/lua-nginx.tar.gz \
    && rm -f /tmp/lua-resty-core.tar.gz \
    && rm -f /tmp/lua-resty-lrucache.tar.gz \
    && rm -rf /tmp/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
    && rm -rf /tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} \
    && rm -rf /tmp/headers-more-nginx-module-${HEADERS_MORE_NGINX_MODULE} \
    && rm -rf /tmp/echo-nginx-module-${ECHO_NGINX_MODULE_VERSION} \
    && rm -rf /tmp/nginx-http-concat-${HTTP_CONCAT_NGINX_MODULE_VERSION} \
    && rm -rf /tmp/nginx-brotli \
    && rm -rf /tmp/lua-resty-core-${LUA_RESTY_CORE_VERSION}  \
    && rm -rf /tmp/lua-resty-lrucache-${LUA_RESTY_LRUCACHE_VERSION} \
    && cd /tmp \
    && curl -fSL https://github.com/luarocks/luarocks/archive/refs/tags/v${LUAROCKS_VERSION}.tar.gz -o luarocks.tar.gz \
    && tar -xvf luarocks.tar.gz \  
    && cd luarocks-${LUAROCKS_VERSION} \
    && ./configure && make && make install \
    && cd /tmp \
    && rm -rf luarocks.tar.gz \
    && rm -rf luarocks-${LUAROCKS_VERSION} \
    && apk add --no-cache --virtual .gettext gettext \
    && mv /usr/bin/envsubst /tmp/ \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
        | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
        | sort -u \
        | xargs -r apk info --installed \
        | sort -u \
        )" \
    && apk add --no-cache --virtual .nginx-rundeps $runDeps \
    && apk del .build-deps \
    && apk del .gettext \
    && rm -rf /tmp/luajit2-${OPENRESTY_LUAJIT_VERSION} \
    && mv /tmp/envsubst /usr/local/bin/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

ENV LUA_PATH="/usr/local/lib/lua/?.lua;/etc/nginx/lua/?.lua;/usr/local/share/lua/5.1/?.lua"
ENV LUA_CPATH="/etc/nginx/modules/?.so;/usr/local/lib/lua/5.1/?.so"

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]