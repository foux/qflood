FROM cr.hotio.dev/hotio/base@sha256:a5b4a850b6128d497dd55ea28290133352a80b9992a29e0a6e7918b4021d2ab5

ENV VPN_ENABLED="false" VPN_LAN_NETWORK="" VPN_CONF="wg0" VPN_ADDITIONAL_PORTS="" FLOOD_AUTH="false" WEBUI_PORTS="8080/tcp,8080/udp,3000/tcp,3000/udp" PRIVOXY_ENABLED="false" S6_SERVICES_GRACETIME=180000

EXPOSE 3000 8080

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/qBittorrent"

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main privoxy iptables iproute2 openresolv wireguard-tools && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community ipcalc mediainfo

ARG QBITTORRENT_FULL_VERSION

RUN curl -fsSL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${QBITTORRENT_FULL_VERSION}/x86_64-qbittorrent-nox" > "${APP_DIR}/qbittorrent-nox" && \
    chmod +x "${APP_DIR}/qbittorrent-nox"

ARG FLOOD_VERSION
RUN curl -fsSL "https://github.com/jesec/flood/releases/download/v${FLOOD_VERSION}/flood-linux-x64" > "${APP_DIR}/flood" && \
    chmod 755 "${APP_DIR}/flood"

COPY root/ /
