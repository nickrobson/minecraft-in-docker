ARG JAVA_VERSION
FROM eclipse-temurin:${JAVA_VERSION}-alpine

ARG SERVER_JAR_URL
ARG SERVER_JAR_SHA1
ARG SERVER_JAR_SIZE
ARG SERVER_VERSION

VOLUME ["/data"]
RUN mkdir -p /data
WORKDIR /data

RUN apk update \
    && apk upgrade \
    && apk --no-cache add curl \
    && mkdir -p /minecraft \
    && curl -L "${SERVER_JAR_URL}" -o "/minecraft/minecraft_server.jar" \
    && (test "$(stat -c "%s" "/minecraft/minecraft_server.jar")" = "${SERVER_JAR_SIZE}" || (echo "size mismatch" && exit 1)) \
    && (test "$(sha1sum -b "/minecraft/minecraft_server.jar" | cut -d' ' -f1)" = "${SERVER_JAR_SHA1}" || (echo "sha1 checksum mismatch" && exit 1))

COPY start-server.sh /minecraft/start-server.sh

ENV EULA=false
ENV MEMORY=2G
ENTRYPOINT ["sh", "/minecraft/start-server.sh"]