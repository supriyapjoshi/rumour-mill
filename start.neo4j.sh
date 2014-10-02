
set -e

export DOCKER_HOST=tcp://$(boot2docker ip 2>/dev/null):2375
docker build -t neo4j docker/neo4j

echo "Starting neo4j"

docker run -d neo4j

echo "Neo4j now available on INSERT PORT HERE"
