# tlss-docker

Docker-обёртка для проекта [addspin/tlss](https://github.com/addspin/tlss).

Проект позволяет запускать **tlss** в Docker-контейнере с использованием `Docker Compose`, автоматически выбирая подходящую архитектуру и последнюю доступную версию приложения.

## Возможности

* 🐳 Запуск **tlss** в Docker
* ⚙️ Поддержка **Docker Compose**
* 🏗️ Автоматическое определение архитектуры:

  * `AMD64`
  * `ARM64`
* 🔄 Автоматическое определение **последнего release/tag** репозитория `addspin/tlss`
* 📦 **Multi-stage Docker build** для уменьшения размера итогового образа
* 🔧 Конфигурация `tlss` подключается через volume
* 🔒 Минимальный runtime-образ без инструментов, необходимых только для загрузки и распаковки приложения

## Структура проекта

```text
tlss-docker/
├── configs/
│   └── config.yaml
├── Dockerfile
├── docker-compose.yml
└── README.md
```

## Запуск

Клонируйте репозиторий:

```bash
git clone https://github.com/klanet/tlss-docker
cd tlss-docker
```

Запустите контейнер:

```bash
docker compose up -d --build
```

Docker автоматически определит архитектуру текущей системы и загрузит соответствующий бинарный файл `tlss`.

## Архитектура

При сборке используется переменная Docker BuildKit `TARGETARCH`.

В зависимости от платформы будет загружен соответствующий release:

```text
linux/amd64 → tlss-linux-amd64.tar.gz
linux/arm64 → tlss-linux-arm64.tar.gz
```

Таким образом, один `Dockerfile` может использоваться на системах с разной архитектурой.

## Версия tlss

Версия приложения определяется автоматически во время сборки.

Dockerfile получает информацию о последнем release из GitHub-репозитория:

```text
https://github.com/addspin/tlss
```

После определения версии скачивается соответствующий архив для текущей архитектуры.

Например:

```text
GitHub Release
      │
      ▼
  Последний tag
      │
      ▼
Определение архитектуры
      │
      ├── amd64 → tlss-linux-amd64.tar.gz
      │
      └── arm64 → tlss-linux-arm64.tar.gz
      │
      ▼
   Docker image
```

## Конфигурация

Конфигурационный файл находится в:

```text
configs/config.yaml
```

В `docker-compose.yml` он подключается в контейнер:

```yaml
volumes:
  - ./configs/config.yaml:/opt/app/config.yaml
```

Это позволяет изменять конфигурацию без пересборки Docker-образа.

## Порты

По умолчанию публикуются следующие порты:

|    Порт | Назначение          |
| ------: | ------------------- |
| `43000` | UI / EST            |
|  `8080` | CRL                 |
| `43001` | Дополнительный порт |

В текущем `docker-compose.yml` наружу опубликованы:

```text
43000
8080
```

При необходимости `43001` можно добавить в секцию `ports`.

## Обновление tlss

Чтобы получить новый release, пересоберите образ без использования Docker cache:

```bash
docker compose build --no-cache
docker compose up -d
```

Или:

```bash
docker compose build --no-cache tlss-app
docker compose up -d tlss-app
```

Это заставит Docker заново определить последний release и загрузить актуальный бинарный файл.

## Dockerfile

Проект использует **multi-stage build**.

На первом этапе устанавливаются инструменты, необходимые для получения и распаковки `tlss`:

```text
wget
tar
gzip
jq
```

После загрузки бинарный файл передаётся во второй stage.

В итоговый runtime-образ попадают только необходимые компоненты, что позволяет не включать инструменты сборки и временные файлы в production-контейнер.

## Оригинальный проект

Проект основан на:

**addspin/tlss**

https://github.com/addspin/tlss

Все права на оригинальный проект и его исходный код принадлежат соответствующим авторам.