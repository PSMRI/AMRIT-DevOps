#!/bin/bash
set -e

AMRIT_HOME="/home/ramnar/Documents/amrit"
cd "$AMRIT_HOME"

# clone git repository for ECD-API and ECD-UI if not already done
if [ ! -d "ECD-API" ]; then
    git clone https://github.com/PSMRI/ECD-API.git
    cd "$AMRIT_HOME"/ECD-API
    cp src/main/environment/ecd_example.properties src/main/environment/ecd_local.properties
fi
if [ ! -d "ECD-UI" ]; then
    git clone https://github.com/PSMRI/ECD-UI.git
    cd "$AMRIT_HOME"/ECD-UI
    sudo npm install --legacy-peer-deps
    git submodule update --init --recursive
    cp src/environments/environment.local.ts src/environments/environment.ts
fi


gnome-terminal -- bash -c "cd "$AMRIT_HOME"/AMRIT-DevOps/amrit-local-setup;sudo docker-compose up -d"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Common-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/ECD-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/ECD-UI;ng serve; exec bash"
