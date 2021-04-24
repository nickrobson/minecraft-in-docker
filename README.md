# minecraft-in-docker

This repository contains scripts to easily create a docker image for a desired Minecraft version.

Currently, only the official Minecraft server versions are supported.
However, I plan on supporting Minecraft Forge versions in the future.

## Creating a docker image

Make sure you have the required commands installed (listed at the top of `build-image.sh`) then run the command below depending on which version you'd like!

The command creates the image with the name `minecraft-server:VERSION`. If you're using `-r` or `-s`, tags of `minecraft-server:latest` and `minecraft-server:latest-snapshot` are also created, respectively.

### Latest Minecraft release

```sh
./build-image.sh -r
```

### Latest Minecraft snapshot

```sh
./build-image.sh -s
```

### Specific Minecraft version (release or snapshot)

```sh
./build-image.sh -v 1.16.5
```

## Running the server

### Docker Compose

1. Configure your server settings as you want in `docker-compose.yml`
1. Start the server:
    ```sh
    docker compose up
    ```
1. Configure the `server.properties` and any other settings in your Minecraft data mount location (`minecraft-data` by default), restarting the server if you did so.

### Docker CLI

1. Run the command below, changing any arguments as needed.
    ```sh
    docker run -it \
      # EULA=true bypasses the eula.txt check
      -e EULA=true \
      # MEMORY=2G sets the server's memory to 2GB of RAM
      -e MEMORY=2G \
      # Makes the server hosted on 25565 (the default Minecraft server port)
      -p 25565:25565 \
      # Mounts the server's data folder to /path/to/minecraft-data (you'll want this path to be a meaningful folder)
      -v /path/to/minecraft-data:/data \
      # Specifies the docker image that was previously built that you want to run the server with (here it will use 1.16.5)
      minecraft-server:1.16.5
    ```
1. Configure the `server.properties` and any other settings in your Minecraft data mount location (`minecraft-data` by default), restarting the server if you did so.