
#!/bin/bash
set -e

# Set AMRIT_HOME robustly to the parent directory of this script
AMRIT_HOME="$(dirname $(dirname $(realpath $0)))"
cd "$AMRIT_HOME"

echo "[INFO] AMRIT_HOME set to $AMRIT_HOME"

# Clone Common-API if not present
if [ ! -d "$AMRIT_HOME/Common-API" ]; then
    echo "[INFO] Cloning Common-API repository..."
    git clone https://github.com/PSMRI/Common-API.git "$AMRIT_HOME/Common-API"
    cd "$AMRIT_HOME/Common-API"
    cp src/main/environment/common_example.properties src/main/environment/common_local.properties
    echo "[INFO] Common-API environment files copied."
    cd "$AMRIT_HOME"
else
    echo "[INFO] Common-API already exists."
fi

# Clone Common-UI if not present
if [ ! -d "$AMRIT_HOME/Common-UI" ]; then
    echo "[INFO] Cloning Common-UI repository..."
    git clone https://github.com/PSMRI/Common-UI.git "$AMRIT_HOME/Common-UI"
    cd "$AMRIT_HOME"
else
    echo "[INFO] Common-UI already exists."
fi

# Start local setup containers
echo "[INFO] Starting local setup containers..."
gnome-terminal -- bash -c "cd \"$AMRIT_HOME/AMRIT-DevOps/amrit-local-setup\";sudo docker-compose up -d; exec bash"

# Start Common-API service
echo "[INFO] Starting Common-API service..."
gnome-terminal -- bash -c "cd \"$AMRIT_HOME/Common-API\";mvn clean install -DskipTests=true; mvn spring-boot:run -DENV_VAR=local; exec bash"