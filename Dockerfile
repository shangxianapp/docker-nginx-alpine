# update 3.4 to 3.9 for openssl 1.1.1
# refer to https://github.com/gliderlabs/docker-alpine/issues/466
FROM alpine:3.9

LABEL maintainer="Wang Shaobo <fireshooter@163.com>, xuexb <fe.xiaowu@gmail.com>, yugasun <yuga.sun.bj@gmail.com>"
LABEL org.opencontainers.image.source https://github.com/shangxianapp/docker-nginx-alpine

ENV LANG en_US.UTF-8
ENV TZ Asia/Shanghai

COPY scripts/install.sh /root/install.sh
RUN /bin/sh /root/install.sh
RUN rm -f /root/install.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY logrotate.conf /etc/logrotate.d/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]