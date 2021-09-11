#!/bin/bash
#colors 
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

logo () {    
    echo "______  _              __  _          _____  _____  _____ "
    echo "|  ___|(_)            / _|| |        |_   _||_   _||_   _|"
    echo "| |_    _  _ __  ___ | |_ | | _   _    | |    | |    | |  "
    echo "|  _|  | || '__|/ _ \|  _|| || | | |   | |    | |    | |  "
    echo "| |    | || |  |  __/| |  | || |_| |  _| |_  _| |_  _| |_ "
    echo "\_|    |_||_|   \___||_|  |_| \__, |  \___/  \___/  \___/ "
    echo "                               __/ |                      "
    echo "                              |___/                       "
    echo "Utility tool - v1.0"
    echo -e "By quietwalker\n\n"
}

check_dependecies () {
    echo -e "${YELLOW}[*] Checking if system requirements are satisfied ${NOCOLOR}"
    which docker > /dev/null
    dock=$?
    which docker-compose > /dev/null
    dock_comp=$?

    if [ "$dock" -ne 0 ] || [ "$dock_comp" -ne 0 ];then 
        echo -e "${RED}Missing dependences: docker and docker-compose are required to run this script!${NOCOLOR}"
        exit 1 
    else 
        echo -e "${GREEN}[*] Dipendences OK! ${NOCOLOR}"
    fi
}

install () {

check_dependecies


read -p "[*] Please insert the Firefly III database username: " FIREFLY_DB_USR
read -s -p "[*] Please insert the database password for the user ${FIREFLY_DB_USR}:" SECRET_FIREFLY_PWD

echo -e "\n${YELLOW}[*] Downloading Firefly env file ${NOCOLOR}"
curl --silent https://raw.githubusercontent.com/firefly-iii/firefly-iii/master/.env.example -o firefly-env > /dev/null
curl_result=$?

if [ "$curl_result" -ne 0 ]; then
    echo -e "${RED}[!] Error during FireFlyIII envfile download from github ${NOCOLOR}"
    exit 1
else 
    echo -e "${GREEN}[*] Firefly env file downloaded${NOCOLOR}"
fi
APP_KEY_RANDOM=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)

echo -e "${YELLOW}[*] Editing the env file with custom variables ${NOCOLOR}"
sed -i "s|APP_KEY=SomeRandomStringOf32CharsExactly|APP_KEY=$APP_KEY_RANDOM|" firefly-env
sed -i "s|DEFAULT_LANGUAGE=en_US|DEFAULT_LANGUAGE=it_IT|" firefly-env
sed -i "s|TZ=Europe/Amsterdam|TZ=Europe/Rome|" firefly-env
sed -i "s|DB_USERNAME=firefly|DB_USERNAME=$FIREFLY_DB_USR|" firefly-env
sed -i "s|DB_PASSWORD=secret_firefly_password|DB_PASSWORD=$SECRET_FIREFLY_PWD|" firefly-env

echo -e "${YELLOW}[*] Creating Postgres env file ${NOCOLOR}"

cat <<EOF >mysql-env
MYSQL_RANDOM_ROOT_PASSWORD=yes
MYSQL_USER=$FIREFLY_DB_USR
MYSQL_PASSWORD=$SECRET_FIREFLY_PWD
MYSQL_DATABASE=firefly
EOF

echo -e "${YELLOW}[*] Executing docker compose up${NOCOLOR}"
docker-compose -f firefly.yaml up -d 

echo -e "${YELLOW}[*] Containers initialization started.${NOCOLOR}" 
echo -e "${YELLOW}[*] Waiting for container creation. It could take some minutes to be running...${NOCOLOR}"
container_num=$(docker container ls -f name=firefly3 | sed -n '1!p' | wc -l)
counter=0
while [ $container_num -lt 1 ] && [ $counter -lt 20 ]; do
    sleep 5
    counter=$(($counter+1))
done

if [ $counter -lt 20 ]; then
    echo -e "${YELLOW}[*] Displaying container logs...${NOCOLOR}"
    CONTAINER_ID=$(docker ps | grep fireflyiii | awk {'print $1'})
    timeout 30s docker container logs -f $CONTAINER_ID 

    echo -e "${GREEN}[*] Now you should be able to access Firefly from http://localhost using your browser${NOCOLOR}"
else 
    echo -e "${RED}[!] Something went wrong! execute this script with --delete option and retry the installation${NOCOLOR}"
    exit 1
fi 

}

start () {
    docker-compose -f firefly.yaml start
}

stop () {
    docker-compose -f firefly.yaml stop
}

delete_all () {
    stop 
    docker-compose -f firefly.yaml down 
    echo "[*] Deleting all local volumes..."
    docker volume rm firefly3-compose-script_firefly_iii_db firefly3-compose-script_firefly_iii_upload
}


menu () {
    echo -e "\t--install\tInstall FireflyIII from scratch"
    echo -e "\t--start\t\tStart an existing installation of FireflyIII"
    echo -e "\t--stop\t\tStop an already running installation of FireflyIII"
    echo -e "\t--delete\tDelete an existing installation of FireflyIII"

}

logo
args=("$#")
if [ "$args" -eq 0 ] || [ "$args" -gt 1 ];then 
    echo -e "${YELLOW}[!]One argument is expected, ${args} provided!${NOCOLOR}"
    echo -e "\nFirefly III Utility Script"
    menu
    exit 1
fi 

case $1 in

  --install)
    install
    ;;

  --start)
    start
    ;;

  --stop)
    stop
    ;;

  --delete)

    echo "[!] The delete operation will delete all FireFly III data, so all records will be wiped."
    while true; do
        read -p "[!] Do you want to continue? [y/n]: " DEL_VAR
        case $DEL_VAR in
            [Yy]* ) delete_all; break;;
            [Nn]* ) exit;;
            * ) echo "[!] Please answer yes or no.";;
        esac
    done
    ;;

  *)
    echo -e "${YELLOW}[!] Wrong argument! Please run this script again with a correct argument${NOCOLOR}"
    echo -e "Firefly III Utility Script"
    menu
    ;;
esac

echo "Bye Bye"
