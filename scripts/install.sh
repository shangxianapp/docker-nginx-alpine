#!/bin/sh

GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8

CONFIG="\
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
		--with-ld-opt="-Wl,-rpath,/usr/lib" \
		--add-module=/tmp/nginx-brotli \
		--add-module=/tmp/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
		--add-module=/tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION} \
		--add-module=/tmp/echo-nginx-module-${ECHO_NGINX_MODULE_VERSION} \
		--add-module=/tmp/nginx-http-concat-${HTTP_CONCAT_NGINX_MODULE_VERSION} \
	"

# add nginx group
addgroup -S nginx
# add nginx user
adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx -u 1000 nginx

# install dependencies
apk add --no-cache --virtual .build-deps \
	gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    git \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    luajit-dev \

# export variable
export LUAJIT_LIB=/usr/lib
export LUAJIT_INC=/usr/include/luajit-2.0

# install nginx develop kits
curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz -o /tmp/ndk.tar.gz
tar -xvf /tmp/ndk.tar.gz -C /tmp
curl -fSL https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_MODULE_VERSION}.tar.gz -o /tmp/lua-nginx.tar.gz
curl -fSL https://github.com/alibaba/nginx-http-concat/archive/${HTTP_CONCAT_NGINX_MODULE_VERSION}.tar.gz -o /tmp/nginx-http-concat.tar.gz
curl -fSL https://github.com/openresty/echo-nginx-module/archive/v${ECHO_NGINX_MODULE_VERSION}.tar.gz -o /tmp/echo-nginx.tar.gz
tar -xvf /tmp/lua-nginx.tar.gz -C /tmp
tar -xvf /tmp/echo-nginx.tar.gz -C /tmp
tar -xvf /tmp/nginx-http-concat.tar.gz -C /tmp
curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz
git clone --recursive https://github.com/google/ngx_brotli.git /tmp/nginx-brotli
mkdir -p /usr/src
tar -zxC /usr/src -f nginx.tar.gz
rm nginx.tar.gz
cd /usr/src/nginx-$NGINX_VERSION
./configure $CONFIG --with-debug
make -j$(getconf _NPROCESSORS_ONLN)
mv objs/nginx objs/nginx-debug
mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so
mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so
mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so
mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so
./configure $CONFIG
make -j$(getconf _NPROCESSORS_ONLN)
make install
rm -rf /etc/nginx/html/
mkdir /etc/nginx/conf.d/
mkdir -p /usr/share/nginx/html/
install -m644 html/index.html /usr/share/nginx/html/
install -m644 html/50x.html /usr/share/nginx/html/
install -m755 objs/nginx-debug /usr/sbin/nginx-debug
install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so
install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so
install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so
install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so
ln -s ../../usr/lib/nginx/modules /etc/nginx/modules
strip /usr/sbin/nginx*
strip /usr/lib/nginx/modules/*.so
rm -rf /usr/src/nginx-$NGINX_VERSION
rm -f /tmp/ndk.tar.gz
rm -f /tmp/echo-nginx.tar.gz
rm -f /tmp/lua-nginx.tar.gz
rm -rf /tmp/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION}
rm -rf /tmp/lua-nginx-module-${LUA_NGINX_MODULE_VERSION}
rm -rf /tmp/echo-nginx-module-${ECHO_NGINX_MODULE_VERSION}
rm -rf /tmp/nginx-http-concat-${HTTP_CONCAT_NGINX_MODULE_VERSION}
rm -rf /tmp/nginx-brotli

# Bring in gettext so we can get `envsubst`, then throw
# the rest away. To do this, we need to install `gettext`
# then move `envsubst` out of the way so `gettext` can
# be deleted completely, then move `envsubst` back.
apk add --no-cache --virtual .gettext gettext
mv /usr/bin/envsubst /tmp/
runDeps="$( \
		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)"

apk add --no-cache --virtual .nginx-rundeps $runDeps
apk del .build-deps
apk del .gettext
mv /tmp/envsubst /usr/local/bin/

# forward request and error logs to docker log collector
ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log