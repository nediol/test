# test
Тестовое задание

## 1. Подготовка тестового окружения

Проверка версии установленного nginx (установка с помощью самописного скрипта install-nginx-from-source.sh):

<img width="1654" height="179" alt="image" src="https://github.com/user-attachments/assets/6f4aa735-a547-4d25-9782-4966c19568cf" />

---

nginx.service

```ini
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
```

Проверка статуса сервиса nginx:

<img width="755" height="203" alt="image" src="https://github.com/user-attachments/assets/1dfae603-b947-4177-bbc9-77fb8a1a990b" />

- Nginx работает
- systemctl status nginx показывает активное состояние

## 2. Напишите простой .gitlab-ci.yml файл

.gitlab-ci.yml

```yaml
stages:
  - test # стадия проверки установки nginx и вывода его версии

check_nginx:
  stage: test  # задача будет выполняться на этапе test
  script:
    - which nginx && nginx -v  # проверяем, установлен ли nginx и выводим его версию
  # опционально: можно указать теги, если используется кастомный раннер
  tags:
   - nginx
```

Результат выполнения пайплайна на shell раннере:

<img width="1618" height="593" alt="image" src="https://github.com/user-attachments/assets/3175cff5-7de7-49a9-a49a-58dc1a7c8b83" />


- Корректный файл .gitlab-ci.yml с минимальным пайплайном
- Комментарии внутри объясняют, что делает каждая стадия

## 3. Работа с Docker

Dockerfile

```dockerfile
FROM alpine:3.22

# Устанавливаем nginx и правим конфиг
RUN apk add --no-cache nginx && \
    sed -i '/location \//,/}/{s/return 404;/return 200 "Hello from DevOps!\n";\n        add_header Content-Type text\/plain;/}' /etc/nginx/http.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

Проверка:

<img width="1430" height="137" alt="image" src="https://github.com/user-attachments/assets/980f1359-3aae-4ddc-933a-48a7b988ae9b" />

- Рабочий Dockerfile
- Контейнер поднимается и отвечает на curl localhost или через браузер

## 4. (На выбор) Мини-задание по YAML / Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:stable
          ports:
            - containerPort: 80
```

Проверка:

<img width="953" height="68" alt="image" src="https://github.com/user-attachments/assets/2e40ddb6-11ab-4fdc-bc7d-6e81cc7d0dc9" />


## 5. Ответьте письменно на 3 вопроса

Чем отличается apt update от apt upgrade?

- apt update обновляет список доступных пакетов и версий (из репозиториев), но не устанавливает ничего.
- apt upgrade обновляет установленные пакеты до последних доступных версий (на основе обновлённого списка).

Как вы проверите, слушает ли сервис нужный порт?

- ss -tulpn | grep :<порт> - слушает ли порт
- lsof -i :<порт> - показывает процесс, испольщующий порт
- netstat -tulpn | grep :<порт> - ранняя альтернатива ss

Какие команды вы используете для диагностики сетевых проблем?

- ping <адрес> - доступность хоста
- traceroute <адрес> - путь до хоста
- curl -v http://<адрес,домен>:<порт> - для http
- nc -vz - проверка подключения к порту
- dig, host, nslookup - проверка dns
- ip a, ip r, ip link - локальные адреса, маршруты, интерфейсы
- ss -tulpn, lsof -i - открытые порты и сокеты
- tcpdump -i port - сниффинг трафика на порту интерфейса
- nmap - сканирование портов
- iptables -L -n -v - показать все цепочки фаервола с числом пакетов и байт
