# [Nicotine+ Docker Container](https://hub.docker.com/r/khannurien/nicotine)

💡 *This work is essentially a modified version of [realies/soulseek-docker](https://github.com/realies/soulseek-docker)*

![GitHub Workflow Status](https://shields.api-test.nl/github/workflow/status/khannurien/nicotine-docker/build)
![Docker Build](https://img.shields.io/docker/automated/khannurien/nicotine)
![Docker Pulls](https://shields.api-test.nl/docker/pulls/khannurien/nicotine)
![Docker Image Size](https://shields.api-test.nl/docker/image-size/khannurien/nicotine)

![Nicotine+ Docker Container Screenshot](https://i.imgur.com/vvQmPCz.png)

## Prerequisites

- Docker installed on your machine or server
- Port 6080 open and accessible for noVNC web access (or reverse proxied, nginx example at `nicotine.conf`)
- Ports required by Nicotine+ open and forwarded from your router to the Docker host machine

## Setup

1. Map port 6080 on the host machine to port 6080 on the Docker container.
    - If using a GUI or webapp (e.g., Synology) to manage Docker containers, set this configuration option when launching the container from the image.
    - With Docker CLI, use the `-p 6080:6080` option.
2. Map the ports Nicotine+ uses on the Docker container.
    - The first time it runs, Nicotine+ starts up using port `2234`. It can also be manually configured in Options -> Network.
    - Map ports both from your router to the machine hosting the Docker image, and from the outside of the Docker image to the server within it.
3. Launch the Docker container and map the required volumes (see [How to Launch](#how-to-launch) section below).
4. Access the Nicotine+ UI by opening a web browser and navigating to `http://docker-host-ip:6080` or `https://reverse-proxy`, depending on your configuration.
5. During initial setup, change the default downloads path to use the mounted volume (`/data/downloads`).
6. **After initial setup, close the Nicotine+ window to write the configuration file. The application will automatically reopen.**

## Configuration

The container supports the following configuration options:

| Parameter     | Description                                                                   |
| ------------- | ----------------------------------------------------------------------------- |
| `PGID`        | Group ID for the container user (optional, requires `PUID`, default: 1000)    |
| `PUID`        | User ID for the container user (optional, requires `PGID`, default: 1000)     |
| `NOVNC_PORT`  | Port for noVNC web access (optional, default: 6080)                           |
| `UMASK`       | File permission mask for newly created files (optional, default: 022)         |
| `VNCPWD`      | Password for the VNC connection (optional)                                    |
| `VNCPWD_FILE` | Password file for the VNC connection (optional, takes priority over `VNCPWD`) |
| `TZ`          | Timezone for the container (optional, e.g., Europe/Paris, America/Vancouver)  |

## How to Launch

### Using Docker Compose

```yaml
services:
  nicotine:
    platform: linux/amd64
    build: .
    environment:
      - PGID=1000
      - PUID=1000
    ports:
      - 6080:6080
      - 2234:2234
    volumes:
      - config:/data/.config/nicotine
      - data:/data/.local/share/nicotine
      - downloads:/data/downloads
volumes:
  config:
  data:
  downloads:
```

### Using Docker CLI

```bash
docker run -d --name nicotine --restart=unless-stopped \
  -v "/persistent/config":"/data/.config/nicotine" \
  -v "/persistent/data":"/data/.local/share/nicotine" \
  -v "/persistent/downloads":"/data/downloads" \
  -e PGID=1000 \
  -e PUID=1000 \
  -p 6080:6080 \
  khannurien/nicotine
```
