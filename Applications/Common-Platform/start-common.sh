#!/bin/bash
set -e

AMRIT_HOME="/home/ramnar/Documents/amrit"
cd "$AMRIT_HOME"

# clone git repository for Common-API and Common-UI if not already done
if [ ! -d "Common-API" ]; then
    git clone https://github.com/PSMRI/Common-API.git
    cd "$AMRIT_HOME"/Common-API
    cp src/main/environment/common_example.properties src/main/environment/common_local.properties
fi
if [ ! -d "Common-UI" ]; then
    git clone https://github.com/PSMRI/Common-UI.git
fi


gnome-terminal -- bash -c "cd "$AMRIT_HOME"/AMRIT-DevOps/amrit-local-setup;sudo docker-compose up -d"

# start schema management service only first time

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Common-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"