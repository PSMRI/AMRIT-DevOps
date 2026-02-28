
#!/bin/bash
set -e

# Set AMRIT_HOME robustly to the parent directory of this script
AMRIT_HOME="$(dirname $(dirname $(realpath $0)))"
cd "$AMRIT_HOME"
echo "[INFO] AMRIT_HOME set to $AMRIT_HOME"

# Start common services
echo "[INFO] Starting common services..."
start-common.sh

# Clone ECD-API if not present
if [ ! -d "$AMRIT_HOME/ECD-API" ]; then
    echo "[INFO] Cloning ECD-API repository..."
    git clone https://github.com/PSMRI/ECD-API.git "$AMRIT_HOME/ECD-API"
    cd "$AMRIT_HOME/ECD-API"
    cp src/main/environment/ecd_example.properties src/main/environment/ecd_local.properties
    echo "[INFO] ECD-API environment files copied."
    cd "$AMRIT_HOME"
else
    echo "[INFO] ECD-API already exists."
fi

# Clone ECD-UI if not present
if [ ! -d "$AMRIT_HOME/ECD-UI" ]; then
    echo "[INFO] Cloning ECD-UI repository..."
    git clone https://github.com/PSMRI/ECD-UI.git "$AMRIT_HOME/ECD-UI"
    cd "$AMRIT_HOME/ECD-UI"
    sudo npm install --legacy-peer-deps
    git submodule update --init --recursive
    cp src/environments/environment.local.ts src/environments/environment.ts
    echo "[INFO] ECD-UI dependencies installed and environment files copied."
    cd "$AMRIT_HOME"
else
    echo "[INFO] ECD-UI already exists."
fi

# Start ECD-API service
echo "[INFO] Starting ECD-API service..."
gnome-terminal -- bash -c "cd \"$AMRIT_HOME/ECD-API\";mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"

# Start ECD-UI service
echo "[INFO] Starting ECD-UI service..."
gnome-terminal -- bash -c "cd \"$AMRIT_HOME/ECD-UI\";ng serve; exec bash"
