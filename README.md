# docker-nginx-alpine

Nginx Alpine 镜像，支持 [Lua](https://github.com/openresty/lua-nginx-module) 、[nginx-echo](https://github.com/openresty/echo-nginx-module) 、[nginx-brotli](https://github.com/google/ngx_brotli) 、[nginx-http-concat](https://github.com/alibaba/nginx-http-concat) 、WebP 转换、TLSv1.3 、Logrotate 功能。

## 使用

### 构建镜像

```bash
make build
```

### 测试

为了测试 HTTPS 支持，请添加 Hosts `127.0.0.1 www.fe.com` ，并运行：

```bash
make test
```

### 直接覆盖默认配置文件

```bash
docker run -d \
    --name nginx \
    -v "$(pwd)/nginx.conf":/etc/nginx/conf.d/default.conf \
    -p 80:80 \
    -p 443:443 \
    shangxian/nginx:alpine
```

### 自定义配置

```bash
docker run -d \
    --name nginx \
    -v "$(pwd)/nginx.conf":/etc/nginx/nginx.conf \
    -v "$(pwd)/vhost":/etc/nginx/vhost \
    -p 80:80 \
    -p 443:443 \
    shangxian/nginx:alpine
```

## 功能

### Logrotate

默认 Logrotate 会对 `/var/log/nginx/**/*.log` 下的文件进行天级别的备份，你也可以使用覆盖 `/etc/logrotate.d/nginx` 来自定义配置。

## 注意

为了让 Lua 有写入文件权限，在创建 `nginx` 用户时使用了 `-u 1000` 以提高用户权限。

## License

MIT