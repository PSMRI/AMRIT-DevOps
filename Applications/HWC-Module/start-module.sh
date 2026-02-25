cd ../amrit-local-setup
sudo docker-compose up -d

gnome-terminal -- bash -c "cd ../Common-API;mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd ../HWC-API;mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd ../HWC-UI;ng serve; exec bash"
