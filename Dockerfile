ARG DEBIAN_VERSION=trixie-slim

FROM debian:${DEBIAN_VERSION} AS builder

ARG MOSQUITTO_REPO=https://github.com/eclipse/mosquitto.git
ARG MOSQUITTO_TAG=v2.1.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    libssl-dev \
    libcjson-dev \
    libreadline-dev \
    libmicrohttpd-dev \
    libsqlite3-dev \
    xsltproc \
    docbook-xsl \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth 1 --branch ${MOSQUITTO_TAG} ${MOSQUITTO_REPO} mosquitto

WORKDIR /build/mosquitto
RUN cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DWITH_STATIC_LIBRARIES=OFF \
    -DWITH_TLS=ON \
    -DWITH_WEBSOCKETS=ON \
    -DWITH_SRV=ON \
    -DWITH_MICROHTTPD=ON \
    -DWITH_DOCS=OFF \
    -DWITH_TESTS=OFF \
    . \
 && make -j"$(nproc)" \
 && make install DESTDIR=/install

FROM debian:${DEBIAN_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libcjson1 \
    ca-certificates \
    libreadline8t64 \
    libmicrohttpd12t64 \
    libsqlite3-0 \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/lib/mosquitto /var/log/mosquitto /etc/mosquitto

COPY --from=builder /install/usr/sbin/mosquitto /usr/sbin/mosquitto
COPY --from=builder /install/usr/bin/mosquitto_pub /usr/bin/mosquitto_pub
COPY --from=builder /install/usr/bin/mosquitto_sub /usr/bin/mosquitto_sub
COPY --from=builder /install/usr/bin/mosquitto_passwd /usr/bin/mosquitto_passwd
COPY --from=builder /install/usr/lib/libmosquitto* /usr/lib/

COPY mosquitto.conf /etc/mosquitto/mosquitto.conf

LABEL org.opencontainers.image.source="https://github.com/daedaluz/mosquitto" \
      org.opencontainers.image.description="Mosquitto MQTT broker built from source" \
      org.opencontainers.image.licenses="EPL-2.0"

ENV MOSQUITTO_UNSAFE_ALLOW_SYMLINKS=1

EXPOSE 1883 9001

ENTRYPOINT ["/usr/sbin/mosquitto"]
CMD ["-c", "/etc/mosquitto/mosquitto.conf"]
