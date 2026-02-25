#!/bin/bash
set -e

AMRIT_HOME="/home/ramnar/Documents/amrit"
cd "$AMRIT_HOME"

# clone git repository for Helpline104-API and Helpline104-UI if not already done
if [ ! -d "Helpline104-API" ]; then
    git clone https://github.com/PSMRI/Helpline104-API.git
    cd "$AMRIT_HOME"/Helpline104-API
    cp src/main/environment/104_example.properties src/main/environment/104_local.properties
fi
if [ ! -d "Helpline104-UI" ]; then
    cd "$AMRIT_HOME"
    git clone https://github.com/PSMRI/Helpline104-UI.git
    cd "$AMRIT_HOME"/Helpline104-UI
    #npm install --legacy-peer-deps
    git submodule update --init --recursive
    cp src/environments/environment.local.ts src/environments/environment.ts
fi


gnome-terminal -- bash -c "cd "$AMRIT_HOME"/AMRIT-DevOps/amrit-local-setup;sudo docker-compose up -d"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Common-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Helpline104-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Helpline104-UI;ng serve; exec bash"
