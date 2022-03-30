FROM cr.hotio.dev/hotio/base@sha256:3c7a46ceed367269e626f23d7dda736cc3b3759c7651f7aaca35b466fa31f030

ENV VPN_ENABLED="false" VPN_LAN_NETWORK="" VPN_CONF="wg0" VPN_ADDITIONAL_PORTS="" FLOOD_AUTH="false" WEBUI_PORTS="8080/tcp,8080/udp,3000/tcp,3000/udp" PRIVOXY_ENABLED="false" S6_SERVICES_GRACETIME=180000 VPN_IP_CHECK_DELAY=5

EXPOSE 3000 8080

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/qBittorrent"

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main privoxy iptables iproute2 openresolv wireguard-tools && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community ipcalc mediainfo

ARG QBITTORRENT_FULL_VERSION

RUN curl -fsSL "https://github.com/userdocs/qbittorrent-nox-static/releases/download/${QBITTORRENT_FULL_VERSION}/x86_64-icu-qbittorrent-nox" > "${APP_DIR}/qbittorrent-nox" && \
    chmod 755 "${APP_DIR}/qbittorrent-nox"

ARG FLOOD_VERSION
RUN curl -fsSL "https://github.com/jesec/flood/releases/download/v${FLOOD_VERSION}/flood-linux-x64" > "${APP_DIR}/flood" && \
    chmod 755 "${APP_DIR}/flood"

COPY root/ /
