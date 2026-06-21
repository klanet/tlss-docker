FROM alpine:3.24.1

WORKDIR /opt/app

# Копируем бинарный файл приложения

RUN apk add --no-cache wget tar gzip gcompat && \
    wget https://github.com/addspin/tlss/releases/download/v1.4.1/tlss-linux-amd64.tar.gz && \
    tar -xzf tlss-linux-amd64.tar.gz && \
    rm tlss-linux-amd64.tar.gz && \
    chmod +x /opt/app/tlss-linux-amd64
 
# Копируем обновленный конфигурационный файл v1.4.1
COPY ./configs/config.yaml /opt/app/config.yaml

# Делаем файл исполняемым (на случай, если права потерялись при копировании)
RUN chmod +x /opt/app/tlss-linux-amd64

# Открываем порты: старый UI/EST (43000) и новый CRL (8080)
EXPOSE 43000 8080 43001

# Исправленный синтаксис запуска программы
CMD ["/opt/app/tlss-linux-amd64"]
