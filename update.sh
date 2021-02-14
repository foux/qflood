#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    export DOCKER_CLI_EXPERIMENTAL=enabled
    image="hotio/base"
    tag="focal"
    manifest=$(docker manifest inspect ${image}:${tag})
    [[ -z ${manifest} ]] && exit 1
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}.*\$#FROM ${image}@${digest}#g" ./linux-amd64.Dockerfile  && echo "${digest}"
    #digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm" and .platform.os == "linux" and .platform.variant == "v7").digest') && sed -i "s#FROM ${image}.*\$#FROM ${image}@${digest}#g" ./linux-arm-v7.Dockerfile && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}.*\$#FROM ${image}@${digest}#g" ./linux-arm64.Dockerfile  && echo "${digest}"
elif [[ ${1} == "tests" ]]; then
    echo "List installed packages..."
    docker run --rm --entrypoint="" "${2}" apt list --installed
    echo "Check if app works..."
    app_url="http://localhost:3000"
    docker run --network host -d --name service "${2}"
    currenttime=$(date +%s); maxtime=$((currenttime+60)); while (! curl -fsSL "${app_url}" > /dev/null) && [[ "$currenttime" -lt "$maxtime" ]]; do sleep 1; currenttime=$(date +%s); done
    curl -fsSL "${app_url}" > /dev/null
    status=$?
    echo "Show docker logs..."
    docker logs service
    exit ${status}
elif [[ ${1} == "screenshot" ]]; then
    app_url="http://localhost:3000"
    docker run --rm --network host -d --name service "${2}"
    currenttime=$(date +%s); maxtime=$((currenttime+60)); while (! curl -fsSL "${app_url}" > /dev/null) && [[ "$currenttime" -lt "$maxtime" ]]; do sleep 1; currenttime=$(date +%s); done
    docker run --rm --network host --entrypoint="" -u "$(id -u "$USER")" -v "${GITHUB_WORKSPACE}":/usr/src/app/src zenika/alpine-chrome:with-puppeteer node src/puppeteer.js
    exit 0
else
    flood_version=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/jesec/flood/releases/latest" | jq -r .tag_name | sed s/v//g)
    [[ -z ${flood_version} ]] && exit 1
    qbittorrent_full_version=$(curl -fsSL "http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu/dists/focal/main/binary-arm64/Packages.gz" | gunzip -c | grep -A 7 -m 1 "Package: qbittorrent-nox" | awk -F ": " '/Version/{print $2;exit}')
    qbittorrent_version=$(echo "${qbittorrent_full_version}" | sed -e "s/^.*://g" -e "s/~ubuntu.*//g")
    [[ -z ${qbittorrent_version} ]] && exit 1
    version="${qbittorrent_version}--${flood_version}"
    echo '{"version":"'"${version}"'","qbittorrent_version":"'"${qbittorrent_version}"'","qbittorrent_full_version":"'"${qbittorrent_full_version}"'","flood_version":"'"${flood_version}"'"}' | jq . > VERSION.json
fi
