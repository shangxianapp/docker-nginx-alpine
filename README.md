# docker-nginx-alpine
Nginx Alpine 镜像，支持 Lua 、nginx-echo

## 使用

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

## License

MIT