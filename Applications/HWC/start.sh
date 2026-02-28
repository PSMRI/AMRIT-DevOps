
#!/bin/bash
set -e

# Optionally start common services
start-common.sh

# Set AMRIT_HOME to the parent directory if not already set
AMRIT_HOME="$(dirname $(dirname $(realpath $0)))"

# Clone HWC-API and HWC-UI if not already present
if [ ! -d "$AMRIT_HOME/HWC-API" ]; then
	git clone https://github.com/PSMRI/HWC-API.git "$AMRIT_HOME/HWC-API"
	cd "$AMRIT_HOME/HWC-API"
	cp src/main/environment/hwc_example.properties src/main/environment/hwc_local.properties
fi

if [ ! -d "$AMRIT_HOME/HWC-UI" ]; then
	git clone https://github.com/PSMRI/HWC-UI.git "$AMRIT_HOME/HWC-UI"
	cd "$AMRIT_HOME/HWC-UI"
	sudo npm install --legacy-peer-deps
	git submodule update --init --recursive
	cp src/environments/environment.local.ts src/environments/environment.ts
fi

# Start local setup containers
cd "$AMRIT_HOME/amrit-local-setup"
sudo docker-compose up -d

# Start API and UI in new terminals
gnome-terminal -- bash -c "cd \"$AMRIT_HOME/HWC-API\";mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"
gnome-terminal -- bash -c "cd \"$AMRIT_HOME/HWC-UI\";ng serve; exec bash"
