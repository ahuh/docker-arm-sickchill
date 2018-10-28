# Docker ARM SickChill
Docker image dedicated to ARMv7 processors, hosting a SickChill server with WebUI.<br />
<br />
This project is based on existing projects, combined and modified to work on ARMv7 WD My Cloud EX2 Ultra NAS.<br />
See GitHub repositories:
* https://github.com/edv/docker-sickrage
* https://github.com/haugene/docker-transmission-openvpn
<br />
This image is part of a Docker images collection, intended to build a full-featured seedbox, and compatible with WD My Cloud EX2 Ultra NAS (Docker v1.7.0):

Docker Image | GitHub repository | Docker Hub repository
------------ | ----------------- | -----------------
Docker image (ARMv7) hosting a Transmission torrent client with WebUI while connecting to OpenVPN | https://github.com/ahuh/docker-arm-transquidvpn | https://hub.docker.com/r/ahuh/arm-transquidvpn
Docker image (ARMv7) hosting a qBittorrent client with WebUI while connecting to OpenVPN | https://github.com/ahuh/docker-arm-qbittorrentvpn | https://hub.docker.com/r/ahuh/arm-qbittorrentvpn
Docker image (ARMv7) hosting SubZero with MKVMerge (subtitle autodownloader for TV shows) | https://github.com/ahuh/docker-arm-subzero | https://hub.docker.com/r/ahuh/arm-subzero
Docker image (ARMv7) hosting a SickChill server with WebUI | https://github.com/ahuh/docker-arm-sickchill | https://hub.docker.com/r/ahuh/arm-sickchill
Docker image (ARMv7) hosting a NGINX server to secure SickChill, Transmission and qBittorrent | https://github.com/ahuh/docker-arm-nginx | https://hub.docker.com/r/ahuh/arm-nginx

## Installation

### Preparation
Before running container, you have to retrieve UID and GID for the user used to mount your tv shows directory:
* Get user UID:
```
$ id -u <user>
```
* Get user GID:
```
$ id -g <user>
```
The container will run impersonated as this user, in order to have read/write access to the tv shows directory.

### Run container in background
```
$ docker run --name sickchill --restart=always  \
		--add-host=dockerhost:<docker host IP> \
		--dns=<ip of dns #1> --dns=<ip of dns #2> \
		-d \
		-p <webui port>:8081 \
		-v <path to SickChill configuration dir>:/config \
		-v <path to SickChill data dir>:/data \
		-v <path to tv shows dir>:/tvshowsdir \
		-v <path to downloaded files to process>:/postprocessingdir \
		-v /etc/localtime:/etc/localtime:ro \
		-e "AUTO_UPDATE=<auto update SickChill at first start [true/false]>"
		-e "TORRENT_MODE=<transmission or qbittorrent>" \
		-e "TORRENT_PORT=<port of the torrent client>" \
		-e "TORRENT_LABEL=<label to use for SickChill in torrent client>" \
		-e "PROXY_PORT=<squid3 proxy port to use (leave empty to disable)>" \
		-e "PUID=<user uid>" \
		-e "PGID=<user gid>" \
		ahuh/arm-sickchill
```
or
```
$ ./docker-run.sh sickchill ahuh/arm-sickchill
```
(set parameters in `docker-run.sh` before launch)

### Configure SickChill
The container will use volumes directories to manage tv shows files, to retrieve downloaded files, and to store data and configuration files.<br />
<br />
You have to create these volume directories with the PUID/PGID user permissions, before launching the container:
```
/tvshowsdir
/postprocessingdir
/config
/data
```

The container will automatically create a `config.ini` file in the SickChill configuration dir (only if none was present before).<br />
* The following parameters will be automatically modified at launch for compatibility with the Docker container:
```
[General]
...
root_dirs = 0|/tvshowsdir
tv_download_dir = /postprocessingdir
unrar_tool = unrar
```
* Depending on the torrent client Docker container selected (transmission or qbittorrent), these parameters will be automatically modified at launch:
```
[General]
...
use_torrents = 1
torrent_method = ${TORRENT_MODE}
process_automatically = 1
handle_reverse_proxy = 1
...
[TORRENT]
...
torrent_auth_type = none
torrent_host = http://torrent:${TORRENT_PORT}/
torrent_path = /downloaddir/${TORRENT_LABEL}
```
* If a `PROXY_PORT` var is specified, the squid3 hosted on the Docker ARM TranSquidVpn container will be used for searches and indexers in SickChill. These parameters will be automatically modified at launch:
```
[General]
...
proxy_setting = http://dockerhost:${PROXY_PORT}
proxy_indexers = 1
```
* If you use qBittorrent as torrent client, you have to access the search settings in SickChill WebUI, and input the username / password for authentication.

If you modified the `config.ini` file, restart the container to reload SickChill configuration:
```
$ docker stop sickchill
$ docker start sickchill
```
* At the first start of the container, SickChill will automatically be updated from GitHub.

## HOW-TOs

### Get a new instance of bash in running container
Use this command instead of `docker attach` if you want to interact with the container while it's running:
```
$ docker exec -it sickchill /bin/bash
```
or
```
$ ./docker-bash.sh sickchill
```

### Build image
```
$ docker build -t arm-sickchill .
```
or
```
$ ./docker-build.sh arm-sickchill
```
