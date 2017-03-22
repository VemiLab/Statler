#!/bin/bash

# Manages starting and stopping the server.

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function prop {
    grep "${1}" dev.properties|cut -d'=' -f2
}

cmd="${1}"

if [ "$cmd" = "start" ]; then
    echo "Starting the server..."

    # Generate secrets file if it doesn't exist
    if [ ! -f ./config/secrets.yml ]; then
        echo "Secrets file not found. Generating..."
        bash ./make_secrets.sh
        echo ""
    fi

    # Abort if the dev.properties file does not exist
    if [ ! -f ./dev.properties ]; then
        echo -e "./dev.properties not found! Setting up from template."
        cp ./template.properties ./dev.properties
        echo -e "${YELLOW}Make sure to fill in the address you want this server to reside on, then run this command again.${NC}"
        echo ""
        exit
    fi

    # Abort if the dev.properties file is not configured
    if [ "$(prop 'app.server.address')" = "YOUR_ADDRESS_HERE" ]; then
        echo -e "${RED}The address in ./dev.properties is not configured!${NC}"
        echo "Please fill this in and run this command again."
        exit
    fi

    set -e
    # Start the rails server in the background using the given IP address
    rails server -d -b "$(prop 'app.server.address')" 2>&1 | tee server_log.txt
    set +e

    echo 'The server is now running.'

elif [ "$cmd" = "stop" ]; then
    pkill -f rails
    echo 'The server is now shut down.'

#elif [ "$cmd" = "help" ] || [ "$cmd" = "" ]; then
else
    echo "args:"
    echo -e "  start: Starts the server"
    echo -e "  stop:  Stops the server"
fi
