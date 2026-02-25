#!/bin/bash
set -e

AMRIT_HOME="/home/ramnar/Documents/amrit"
cd "$AMRIT_HOME"

# clone git repository for Inventory-API and Inventory-UI if not already done
if [ ! -d "Inventory-API" ]; then
    git clone https://github.com/PSMRI/Inventory-API.git
    cd "$AMRIT_HOME"/Inventory-API
    cp src/main/environment/inventory_example.properties src/main/environment/inventory_local.properties
fi
if [ ! -d "Inventory-UI" ]; then
    git clone https://github.com/PSMRI/Inventory-UI.git
    cd "$AMRIT_HOME"/Inventory-UI
    sudo npm install --legacy-peer-deps
    git submodule update --init --recursive
    cp src/environments/environment.local.ts src/environments/environment.ts
fi


gnome-terminal -- bash -c "cd "$AMRIT_HOME"/AMRIT-DevOps/amrit-local-setup;sudo docker-compose up -d"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Common-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Inventory-API;mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd "$AMRIT_HOME"/Inventory-UI;ng serve; exec bash"
