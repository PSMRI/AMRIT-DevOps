gnome-terminal -- bash -c "cd amrit-local-setup;sudo docker-compose up"

gnome-terminal -- bash -c "cd ../Common-API;mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd ../Admin-API;mvn spring-boot:run -DENV_VAR=local; exec bash"

gnome-terminal -- bash -c "cd ../ADMIN-UI;ng serve; exec bash"
