FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        mingw-w64 \
        nasm \
        pkg-config \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY scripts /scripts

RUN chmod +x /scripts/*.sh

WORKDIR /workspace