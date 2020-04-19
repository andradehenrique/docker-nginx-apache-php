#!/bin/bash
if [ $1 == 'down' ]; then

    docker-compose down

elif [ $1 == 'up' ]; then

    if [[ ! -f "nginx-data/certs/shared.key" ]]; then
        echo "Creating self signed cert....."
        mkdir -p nginx-data/certs
        openssl req -newkey rsa:4096 -nodes -keyout nginx-data/certs/shared.key -x509 -subj "/C=BR/ST=SP/L=Local/O=Dev" -days 3650 -out nginx-data/certs/shared.crt
        echo "....cert created!"
    fi

    docker-compose up -d
fi