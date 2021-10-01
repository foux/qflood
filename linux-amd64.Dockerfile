FROM ghcr.io/hotio/base@sha256:eff47f1189d30e3c1077b420e4ded44d83dab1d24a8df37c210828c30e998a14

ARG DEBIAN_FRONTEND="noninteractive"

ENV VPN_ENABLED="false" VPN_LAN_NETWORK="" VPN_CONF="wg0" VPN_ADDITIONAL_PORTS="" FLOOD_AUTH="false" WEBUI_PORTS="8080/tcp,8080/udp,3000/tcp,3000/udp" PRIVOXY_ENABLED="false" S6_SERVICES_GRACETIME=180000

EXPOSE 3000 8080

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/qBittorrent"

ARG QBITTORRENT_FULL_VERSION

RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        gnupg && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 7CA69FC4 && echo "deb [arch=amd64] http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu focal main" | tee /etc/apt/sources.list.d/qbitorrent.list && \
    apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        qbittorrent-nox=${QBITTORRENT_FULL_VERSION} \
        privoxy \
        mediainfo \
        ipcalc \
        iptables \
        iproute2 \
        openresolv \
        wireguard-tools && \
# clean up
    apt purge -y gnupg && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG FLOOD_VERSION
RUN curl -fsSL "https://github.com/jesec/flood/releases/download/v${FLOOD_VERSION}/flood-linux-x64" > "${APP_DIR}/flood" && \
    chmod 755 "${APP_DIR}/flood"

COPY root/ /
