# update 3.4 to 3.9 for openssl 1.1.1
# refer to https://github.com/gliderlabs/docker-alpine/issues/466
FROM alpine:3.9

LABEL maintainer="Wang Shaobo <fireshooter@163.com>, xuexb <fe.xiaowu@gmail.com>"

ENV LANG en_US.UTF-8
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

ENV NGINX_VERSION 1.14.2
ENV NGX_DEVEL_KIT_VERSION 0.3.0
ENV LUA_NGINX_MODULE_VERSION 0.10.14
ENV ECHO_NGINX_MODULE_VERSION 0.61
ENV HTTP_CONCAT_NGINX_MODULE_VERSION 1.2.2

# Install LUAJIT
RUN apk add --no-cache luajit libwebp-tools

COPY scripts/install.sh /root/install.sh
RUN /bin/sh /root/install.sh
RUN rm -f /root/install.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]