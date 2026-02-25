#!/bin/bash
set -e

AMRIT_HOME="/home/ramnar/Documents/amrit"
cd "$AMRIT_HOME"

# clone git repository for MMU-API and MMU-UI if not already done
if [ ! -d "MMU-API" ]; then
    git clone https://github.com/PSMRI/MMU-API.git
    cd "$AMRIT_HOME"/MMU-API
    cp src/main/environment/common_example.properties src/main/environment/common_local.properties
fi
if [ ! -d "MMU-UI" ]; then
    git clone https://github.com/PSMRI/MMU-UI.git
    cd "$AMRIT_HOME"/MMU-UI
    sudo npm install --legacy-peer-deps
    git submodule update --init --recursive
    cp src/environments/environment.local.ts src/environments/environment.ts
fi


gnome-terminal -- bash -c "cd "$AMRIT_HOME"/AMRIT-DevOps/amrit-local-setup;sudo docker-compose up -d"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Common-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/MMU-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/MMU-UI;ng serve; exec bash"
