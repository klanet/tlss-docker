FROM alpine:3.24.1 AS downloader

ARG TARGETARCH

WORKDIR /tmp

RUN apk add --no-cache wget tar gzip jq && \
    VERSION=$(wget -qO- https://api.github.com/repos/addspin/tlss/releases/latest | \
        jq -r '.tag_name') && \
    echo "Downloading tlss ${VERSION} for ${TARGETARCH}" && \
    wget "https://github.com/addspin/tlss/releases/download/${VERSION}/tlss-linux-${TARGETARCH}.tar.gz" && \
    tar -xzf "tlss-linux-${TARGETARCH}.tar.gz" && \
    mv "tlss-linux-${TARGETARCH}" /tmp/tlss && \
    chmod +x /tmp/tlss


FROM alpine:3.24.1

WORKDIR /opt/app

RUN apk add --no-cache gcompat

COPY --from=downloader /tmp/tlss /opt/app/tlss

EXPOSE 43000 8080 43001

CMD ["/opt/app/tlss"]