#! /bin/bash

SICKCHILL_UPDATED_FILE=/etc/sickchill/updated

if [ "${AUTO_UPDATE}" = true ] && [ ! -e "${SICKCHILL_UPDATED_FILE}" ] ; then
	# First start of the docker container with AUTO_UPDATE env enabled: update SickChill from GitHub
	echo "UPDATE SICKCHILL"
	
	rm -rf /opt/sickchill
	mkdir -p /opt/sickchill
	git clone --depth 1 https://github.com/SickChill/SickChill.git /opt/sickchill
	
	touch ${SICKCHILL_UPDATED_FILE}
fi
