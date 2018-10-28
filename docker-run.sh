#!/bin/sh

# =======================================================================================
# Run Docker container
#
# The container is launched in background as a daemon. It is configured to restart
# automatically, even after host OS restart, unless it is stopped manually with the
# 'docker stop' command 
# =======================================================================================

# ------------------------------------------------------
# Custom parameters

export DOCKERHOST=$(ip route | grep docker | awk '{print $NF}')
export DNS_1=8.8.8.8
export DNS_2=8.8.4.4

export V_CONFIG=/shares/P2P/tools/sickchill
export V_DATA=/shares/P2P/tools/sickchill/data
export V_TVSHOWS_DIR=/shares/Data/Series
export V_POST_PROCESSING_DIR=/shares/P2P/complete/SickChill

export P_PORT=8081

export E_AUTO_UPDATE=true
# Torrent mode = transmission or qbittorrent
export E_TORRENT_MODE=transmission
#export E_TORRENT_MODE=qbittorrent
export E_TORRENT_PORT=9091
#export E_TORRENT_PORT=8082
export E_TORRENT_LABEL=SickChill

# Comment proxy port var to disable use of proxy for searches and indexers in SickChill
export E_PROXY_PORT=3128

export E_PUID=500
export E_PGID=1000

# ------------------------------------------------------
# Common parameters

export CONTAINER_NAME=sickchill
export IMAGE_NAME_1=arm-sickchill
export IMAGE_NAME_2=ahuh/arm-sickchill
export IMAGE_NAME=

if [[ "$1" = "h" ]] || [[ "$1" = "help" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "-help" ]] || [[ "$1" = "--h" ]] || [[ "$1" = "--help" ]]; then
    echo 'Run a Docker container.'
    echo ''
    echo 'Usage:'    
    echo '  docker-run.sh [CONTAINER_NAME] [IMAGE_NAME]'
    echo '  docker-run.sh h | help | -h | -help | --h | --help'
    echo ''
    echo 'Options:'
    echo "  CONTAINER_NAME  Name of the container [default: ${CONTAINER_NAME}]"
    echo "  IMAGE_NAME      Name of the image [default: ${IMAGE_NAME_1} (if exists), ${IMAGE_NAME_2} (otherwise)]"
    echo ''
    exit 1
fi

if [[ $1 ]]; then
	CONTAINER_NAME=$1
else
	echo "Using default container name: ${CONTAINER_NAME}"
fi
if [[ $2 ]]; then
	IMAGE_NAME=$2
else
	if [[ $(docker images | awk '{ print $1,$3 }' | grep -E "^${IMAGE_NAME_1}\s" | wc -l) != 0 ]] ; then
		IMAGE_NAME=${IMAGE_NAME_1}
	else
		IMAGE_NAME=${IMAGE_NAME_2}
	fi
	echo "Using default image name: ${IMAGE_NAME}"
fi

# ------------------------------------------------------
# Common commands

if [[ $(docker ps -f name=${CONTAINER_NAME} -f status=running | grep ${CONTAINER_NAME} | wc -l) != 0 ]] ; then
	# Container already running: stop it
	echo "Stop running container: ${CONTAINER_NAME}"
	docker stop ${CONTAINER_NAME}
	RESULT=$?
	if [[ ${RESULT} != 0 ]] ; then
		exit 1
	fi
fi

if [[ $(docker ps -a -f name=${CONTAINER_NAME} | grep ${CONTAINER_NAME} | wc -l) != 0 ]] ; then
	# Container already exists: remove it
	echo "Remove existing container: ${CONTAINER_NAME}"
	docker rm ${CONTAINER_NAME}
	RESULT=$?
	if [[ ${RESULT} != 0 ]] ; then
		exit 1
	fi
fi

# ------------------------------------------------------
# Custom commands

echo "Run container: ${CONTAINER_NAME}"
docker run --name ${CONTAINER_NAME} --restart=always --add-host=dockerhost:${DOCKERHOST} --dns=${DNS_1} --dns=${DNS_2} -d -p ${P_PORT}:8081 -v ${V_CONFIG}:/config -v ${V_DATA}:/data -v ${V_TVSHOWS_DIR}:/tvshowsdir -v ${V_POST_PROCESSING_DIR}:/postprocessingdir -v /etc/localtime:/etc/localtime:ro -e "AUTO_UPDATE=${E_AUTO_UPDATE}" -e "TORRENT_MODE=${E_TORRENT_MODE}" -e "TORRENT_PORT=${E_TORRENT_PORT}" -e "TORRENT_LABEL=${E_TORRENT_LABEL}" -e "PROXY_PORT=${E_PROXY_PORT}" -e "PUID=${E_PUID}" -e "PGID=${E_PGID}" ${IMAGE_NAME}

