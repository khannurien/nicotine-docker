FROM --platform=linux/amd64 ubuntu:latest

ARG S6_OVERLAY_VERSION=3.1.6.2

COPY ui.patch /tmp

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y binutils ca-certificates curl dbus fonts-noto-cjk locales libegl1 openbox patch python3-numpy software-properties-common tigervnc-standalone-server tigervnc-tools tzdata xz-utils --no-install-recommends

RUN add-apt-repository ppa:nicotine-team/stable && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y nicotine

RUN dbus-uuidgen > /etc/machine-id && \
    locale-gen en_US.UTF-8

RUN curl -fL# https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz -o /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    rm -rf /tmp/s6-overlay-noarch.tar.xz

RUN curl -fL# https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz -o /tmp/s6-overlay-x86_64.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    rm -rf /tmp/s6-overlay-x86_64.tar.xz

RUN mkdir /usr/share/novnc && \
    curl -fL# https://github.com/novnc/noVNC/archive/master.tar.gz -o /tmp/novnc.tar.gz && \
    tar -xf /tmp/novnc.tar.gz --strip-components=1 -C /usr/share/novnc && \
    mkdir /usr/share/novnc/utils/websockify && \
    curl -fL# https://github.com/novnc/websockify/archive/master.tar.gz -o /tmp/websockify.tar.gz && \
    tar -xf /tmp/websockify.tar.gz --strip-components=1 -C /usr/share/novnc/utils/websockify && \
    curl -fL# 'https://avatars.githubusercontent.com/u/20911523?s=200&v=4' -o /usr/share/novnc/app/images/nicotine.png && \
    curl -fL# https://site-assets.fontawesome.com/releases/v6.0.0/svgs/solid/cloud-arrow-down.svg -o /usr/share/novnc/app/images/downloads.svg && \
    curl -fL# https://site-assets.fontawesome.com/releases/v6.0.0/svgs/solid/comments.svg -o /usr/share/novnc/app/images/logs.svg && \
    bash -c 'sed -i "s/<path/<path style=\"fill:white\"/" /usr/share/novnc/app/images/{downloads,logs}.svg' && \
    patch /usr/share/novnc/vnc.html < /tmp/ui.patch && \
    sed -i 's/10px 0 5px/8px 0 6px/' /usr/share/novnc/app/styles/base.css

RUN userdel -f $(id -nu 1000) || true && \
    groupdel -f $(id -ng 1000) || true && \
    rm -rf /home && \
    useradd -u 1000 -U -d /data -s /bin/false nicotine && \
    usermod -G users nicotine

VOLUME /data/.config/nicotine
VOLUME /data/.local/share/nicotine
VOLUME /data/downloads

RUN ln -s /data/downloads /usr/share/novnc/downloads

RUN apt-get purge -y binutils curl patch software-properties-common xz-utils && \
     apt-get autoremove -y && \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV DISPLAY=:1 \
    HOME=/tmp \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    NOVNC_PORT=6080 \
    PGID=1000 \
    PUID=1000 \
    UMASK=022 \
    XDG_RUNTIME_DIR=/tmp

COPY rootfs /

ENTRYPOINT ["/init"]
