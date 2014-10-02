set -e
echo "+-----------------------------------------------------------------+
|                                                                 |
|    Welcome to the RumourMill setup for OSX based folks.         |
|                                                                 |
|                                                                 |
|                                                                 |
|  Enjoy the show...                                              |
|                                                                 |
|                                                                 |
+-----------------------------------------------------------------+
"

function command-check(){
    echo "Checking for existence of $1"
    which $1 > /dev/null

    echo "OK!"
}

function check-deps(){
    command-check "boot2docker"
    command-check "docker"
}

trap "echo Cannot find dependency. Install via homebrew or similar." EXIT
check-deps

trap "" EXIT

echo "Setting up boot2docker if it has not already been done:"

boot2docker status || boot2docker init

echo "Starting the boot2docker VM:"

boot2docker up 2> /dev/null

echo "Starting the neo4j docker container:"

./start.neo4j.sh

