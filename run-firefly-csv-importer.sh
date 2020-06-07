#!/bin/bash
PERSONAL_ACCESS_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYTZkYTY2MGQ4OGJlNmI3MGI2MjczOGU5YjE1MDE3YTk4NTRlNWUzNWEzNzM5MDgzOGVjMTMwZWU0ZWM4NDIxOGJkNzIzMGZiNjA3ZTdlOTkiLCJpYXQiOjE1OTE0NTkyODQsIm5iZiI6MTU5MTQ1OTI4NCwiZXhwIjoxNjIyOTk1Mjg0LCJzdWIiOiIxIiwic2NvcGVzIjpbXX0.mZZ2NqJSwLfvgDaq0muycI2IELfQJWTDYfpzGX5haU9OOXtqhDpt4qKBVMcfuNwjyCIV292irY43zksxgzVQia4s28PUkp4x2mkjGjioPhhMgz4BiWdSSSqrA0GWzC9P5c0R1pG2GdzU9MLqCS9xupEZHRFq3HeP2cuTRyU5Mv3gP-oqD9S2O0pBA36flS26t2eMg5DBUsTWiZnIxB2JCZCiEWxJyjO0HCll5A5M7VkiaKgb5Ybi0U4rPwxNMJZITpWGHnfDajCv6Znah0AftEJmIcEYRZjpvmEAq1LC2_oZnLj6fhJ1RFkcw4v-S14q9hP1StSFV_KVBWECMAsGwQezwcPThDa8LBo5vr424n8EkYyTFu07tnYNJbgZDUWtGj5D-aOD4jLTwsN4DGVU43VqZ8HMBg14TC3QH85FJi9q8of0K3LV4R-FU6H46gVBI24wQYuqQKS9JrssvXSNoo-l2Y5ufCNLp2vZrRRGfQju-xEYYazkpr_OQcwkFV87gzN4rbMfVVUXf86B8KM3LukJLZww-PTcjuA6UtUkFuNiW1eOYoOWjs6puiokplqKs8HKT9orpLatMTzF-W9XM7Gw0dGosLvP3p0wi2_GGnBIjnlqUPflju8qXvH9ogO1RMDg9pBZ_43oA3PPRj5W6OJGnOX3RLW-SqzeNDZOzb8

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