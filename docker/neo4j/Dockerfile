FROM ubuntu:latest
run sudo apt-get update
run apt-get install -y wget
run wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add - 
run echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list
run apt-get update ; apt-get install neo4j -y
