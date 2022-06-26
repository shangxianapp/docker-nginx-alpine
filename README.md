# docker-nginx-alpine

Nginx v1.14.2 Alpine 镜像，支持 以下模块：

- [lua-nginx-module](https://github.com/openresty/lua-nginx-module)
- [nginx-echo](https://github.com/openresty/echo-nginx-module)
- [nginx-brotli](https://github.com/google/ngx_brotli)
- [nginx-http-concat](https://github.com/alibaba/nginx-http-concat) 
- [ngx_headers_more](https://github.com/openresty/headers-more-nginx-module)
- [openresty/lua-resty-core](https://github.com/openresty/lua-resty-core)
- [openresty/lua-resty-lrucache](https://github.com/openresty/lua-resty-lrucache)
- [LuaRocks 3.8.0](https://github.com/luarocks/luarocks)
- WebP 转换
- TLSv1.3

## 使用

### 直接覆盖默认配置文件

```
# ./nginx.conf
server {
    ...
}
```

```bash
docker run \
    --name nginx \
    -v "$(pwd)/nginx.conf":/etc/nginx/conf.d/default.conf \
    -p 80:80 \
    -p 443:443 \
    ghcr.io/shangxianapp/nginx:latest-alpine
```

### 自定义 Nginx 入口配置

```bash
docker run \
    --name nginx \
    -v "$(pwd)/nginx.conf":/etc/nginx/nginx.conf \
    -v "$(pwd)/vhost":/etc/nginx/vhost \
    -p 80:80 \
    -p 443:443 \
    ghcr.io/shangxianapp/nginx:latest-alpine
```

## 功能

二次 LuaRocks 安装：

```dockerfile
FROM ghcr.io/shangxianapp/nginx:latest-alpine

WORKDIR /etc/nginx

RUN luarocks install lua-cjson
RUN luarocks install luasocket

COPY . .

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]%
```

## 注意

为了让 Lua 有写入文件权限，在创建 `nginx` 用户时使用了 `-u 1000` 以提高用户权限。

## 开发

### 构建镜像

```bash
make build
```

### 测试

为了测试 HTTPS 支持，请添加 Hosts `127.0.0.1 www.fe.com` ，并运行：

```bash
make test
```

## License

MIT