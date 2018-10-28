#! /bin/bash

. /etc/sickchill/updateSickChill.sh

. /etc/sickchill/userSetup.sh

echo "PREPARING SICKCHILL CONFIG"
. /etc/sickchill/prepareConfig.sh

echo "STARTING SICKCHILL"
sudo -u ${RUN_AS} python /opt/sickchill/SickBeard.py --config=${SICKCHILL_CONFIG_FILE} --datadir=/data/