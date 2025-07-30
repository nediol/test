FROM alpine:3.22

# Устанавливаем nginx и правим конфиг
RUN apk add --no-cache nginx && \
    sed -i '/location \//,/}/{s/return 404;/return 200 "Hello from DevOps!\n";\n        add_header Content-Type text\/plain;/}' /etc/nginx/http.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

