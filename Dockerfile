FROM adoptopenjdk:11-jre

ARG SERVER_JAR_URL
ARG SERVER_JAR_SHA1
ARG SERVER_JAR_SIZE
ARG SERVER_VERSION

VOLUME ["/data"]
RUN mkdir -p /data
WORKDIR /data

RUN mkdir -p /minecraft && curl -L "${SERVER_JAR_URL}" -o "/minecraft/minecraft_server.jar"

COPY start-server.sh /minecraft/start-server.sh

ENV EULA=false
ENV MEMORY=2G
ENTRYPOINT ["sh", "/minecraft/start-server.sh"]