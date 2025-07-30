#!/bin/bash

set -e  # прерывать скрипт при ошибке

# === установка зависимостей ===
echo "[*] Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    libpcre3 libpcre3-dev \
    zlib1g zlib1g-dev \
    libssl-dev \
    libgd-dev \
    libxml2 libxml2-dev \
    uuid-dev

# === загрузка и распаковка исходников Nginx ===
echo "[*] Downloading Nginx source..."
wget https://nginx.org/download/nginx-1.28.0.tar.gz

echo "[*] Extracting source..."
tar -zxvf nginx-1.28.0.tar.gz
cd nginx-1.28.0

# === конфигурация сборки ===
echo "[*] Configuring build..."
./configure \
    --prefix=/var/www/html \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --with-pcre \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/var/run/nginx.pid \
    --with-http_ssl_module \
    --with-http_image_filter_module=dynamic \
    --modules-path=/etc/nginx/modules \
    --with-http_v2_module \
    --with-stream=dynamic \
    --with-http_addition_module \
    --with-http_mp4_module

# === сборка и установка ===
echo "[*] Building Nginx..."
make
sudo make install

# проверка версии
nginx -V

# === создание systemd-сервиса ===
echo "[*] Creating systemd service for Nginx..."
sudo tee /etc/systemd/system/nginx.service > /dev/null <<EOF
[Unit]
Description=Custom Nginx from source
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/usr/sbin/nginx -s quit
PIDFile=/var/run/nginx.pid
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# === активация и запуск nginx ===
echo "[*] Enabling and starting Nginx..."
sudo systemctl daemon-reload
sudo systemctl enable --now nginx.service

# === проверка статуса ===
sudo systemctl status nginx.service
