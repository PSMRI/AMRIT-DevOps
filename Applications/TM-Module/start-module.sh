#!/bin/bash
set -e

AMRIT_HOME="/home/ramnar/Documents/amrit"
cd "$AMRIT_HOME"

# clone git repository for TM-API and TM-UI if not already done
if [ ! -d "TM-API" ]; then
    git clone https://github.com/PSMRI/TM-API.git
    cd "$AMRIT_HOME"/TM-API
    cp src/main/environment/common_example.properties src/main/environment/common_local.properties
fi
if [ ! -d "TM-UI" ]; then
    git clone https://github.com/PSMRI/TM-UI.git
    cd "$AMRIT_HOME"/TM-UI
    sudo npm install --legacy-peer-deps
    git submodule update --init --recursive
    cp src/environments/environment.local.ts src/environments/environment.ts
fi


gnome-terminal -- bash -c "cd "$AMRIT_HOME"/AMRIT-DevOps/amrit-local-setup;sudo docker-compose up -d"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Common-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/TM-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/TM-UI;ng serve; exec bash"
