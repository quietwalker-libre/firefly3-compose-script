#!/bin/bash
PERSONAL_ACCESS_TOKEN=ey...

FIREFLY_III_URI=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker container ls -a -f name=fireflyiii --format="{{.ID}}"))

echo "[*] Launching the Firefly III CSV importer container"
docker run -d \
-e FIREFLY_III_ACCESS_TOKEN=$PERSONAL_ACCESS_TOKEN \
-e FIREFLY_III_URI=$FIREFLY_III_URI \
-p 8081:80 \
fireflyiii/csv-importer:latest

CONTAINER_ID=$(docker ps | grep csv-importer:latest | awk {'print $1'})

echo "[*] Connecting Firefly CSV importer to the FireFlyIII Network..."
docker network connect firefly3-compose-script_default $CONTAINER_ID

echo "[*] Display CSV importer container bootstrap logs..." 
CONTAINER_ID=$(docker ps | grep csv-importer:latest | awk {'print $1'})
timeout 20s docker container logs -f $CONTAINER_ID 

echo "[*] Now you should be able to upload your CSV file visiting the page http://localhost:8081/"
