#!/usr/bin/env bash

# Required commands:
# - bash
# - docker
# - jq

set -o errexit
set -o nounset
set -o pipefail

IMAGE_NAME="minecraft-server"

main() {
    echo "Fetching Minecraft versions manifest..."
    MANIFEST="$(curl -sSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json')"
    LATEST_RELEASE=$(echo "${MANIFEST}" | jq -r .latest.release)
    LATEST_SNAPSHOT=$(echo "${MANIFEST}" | jq -r .latest.snapshot)

    VERSION="${VERSION:-}"
    EXTRA_TAG=''

    while getopts 'rsv:' flag
    do
        case "$flag" in
            r) VERSION="${LATEST_RELEASE}" EXTRA_TAG="latest";;
            s) VERSION="${LATEST_SNAPSHOT}" EXTRA_TAG="latest-snapshot";;
            v) VERSION="${OPTARG}";;
        esac
    done

    if [ "${VERSION}" = "" ]; then
        echo >&2 "No version(s) specified for generation"
        echo >&2 "  -r            use latest release"
        echo >&2 "  -s            use latest snapshot"
        echo >&2 "  -v VERSION    use specified version"
        exit 1
    fi

    echo "Searching for version ${VERSION} in manifest..."
    VERSION_MANIFEST="$(echo "${MANIFEST}" | jq ".versions[] | select(.id == \"${VERSION}\")")"

    VERSION_TYPE="$(echo "${VERSION_MANIFEST}" | jq -r .type)"
    VERSION_RELEASE_DATE="$(echo "${VERSION_MANIFEST}" | jq -r '.releaseTime | sub("[+]00:00$";"Z") | fromdateiso8601 | strflocaltime("%d %B %Y")')"
    VERSION_MANIFEST_URL="$(echo "${VERSION_MANIFEST}" | jq -r .url)"

    echo "Found ${VERSION_TYPE} version ${VERSION} released on ${VERSION_RELEASE_DATE}"

    echo "Fetching Minecraft ${VERSION} version manifest..."
    SERVER_DOWNLOAD_MANIFEST="$(curl -sSL "${VERSION_MANIFEST_URL}" | jq .downloads.server)"

    SERVER_JAR_URL="$(echo ${SERVER_DOWNLOAD_MANIFEST} | jq -r .url)"
    SERVER_JAR_SHA1="$(echo ${SERVER_DOWNLOAD_MANIFEST} | jq -r .sha1)"
    SERVER_JAR_SIZE="$(echo ${SERVER_DOWNLOAD_MANIFEST} | jq -r .size)"

    BUILD_ROOT="$(realpath $(dirname "$0"))"

    EXTRA_TAG_ARG=''
    if [ "${EXTRA_TAG}" != "" ]; then
        EXTRA_TAG_ARG="--tag ${IMAGE_NAME}:${EXTRA_TAG}"
    fi

    docker build \
        --build-arg SERVER_JAR_URL="${SERVER_JAR_URL}" \
        --build-arg SERVER_JAR_SHA1="${SERVER_JAR_SHA1}" \
        --build-arg SERVER_JAR_SIZE="${SERVER_JAR_SIZE}" \
        --build-arg SERVER_VERSION="${VERSION}" \
        --file Dockerfile \
        --tag "${IMAGE_NAME}:${VERSION}" \
        ${EXTRA_TAG_ARG} \
        "${BUILD_ROOT}"

    echo
    echo "Docker image built for the Minecraft ${VERSION} server with tags:"
    echo "  ${IMAGE_NAME}:${VERSION}"
    if [ "${EXTRA_TAG}" != "" ]; then
        echo "  ${IMAGE_NAME}:${EXTRA_TAG}"
    fi
}

main $@