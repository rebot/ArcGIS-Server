include .env
export

.PHONY: all usage test build

RED=\033[0;31m
PURPLE=\033[0;35m
CYAN=\033[0;36m
NC=\033[0m

all: usage

usage:
	@echo "use ${PURPLE}\`make test\`${NC} and ${PURPLE}\`make build\`${NC}"

test: 
	@echo "\nBuilding ${PURPLE}TEST${NC} Images"
	@echo "----------------------------------"
	@echo "Building the docker images for the ${CYAN}Server${NC} and ${CYAN}Datacore${NC} environment\n"
	docker build -t arcgisserver:test -f "ArcGIS Server/Dockerfile" "ArcGIS Server" 
	docker build -t arcgisdatacore:test -f "ArcGIS Datacore/Dockerfile" "ArcGIS Datacore"
	echo "\n${PURPLE}INFO:${NC} Those images will be used in Docker Compose"

build: 
	@echo "\nBuilding ${PURPLE}PRODUCTION${NC} Images"
	@echo "----------------------------------"
	@echo "Building the docker images for the ${CYAN}Server${NC} and ${CYAN}Datacore${NC} environment\n"
	docker build --no-cache -t arcgisserver:production -f "ArcGIS Server/Dockerfile" "ArcGIS Server" 
	docker build --no-cache -t arcgisdatacore:production -f "ArcGIS Datacore/Dockerfile" --build-arg POSTGRES_USER=${POSTGRES_USER} --build-arg POSTGRES_PASSWORD=${POSTGRES_PASSWORD} "ArcGIS Datacore"
	@echo "\n${RED}WARNING:${NC} Credentials from the ${PURPLE}\`.env\`${NC} file are used to configure the Datacore"
	@echo "${PURPLE}INFO:${NC} Those images will be used in Docker Compose"

run: 
	@echo "\nRun the ${PURPLE}PRODUCTION${NC} Environment"
	@echo "----------------------------------"
	@echo "Start an instance of the ${CYAN}Datacore${NC}\n"
	@make clean # Cleanup running instances
	docker network create arcgisserver
	docker run -d --name arcgisdatacore --network arcgisserver -p 2345:5432 arcgisdatacore:production
	@echo "\n${PURPLE}INFO:${NC} ArcGIS Datacore is up and running on Port \`2345\`"

clean:
	@docker ps -a -q | xargs docker stop > /dev/null
	@docker ps -a -q | xargs docker rm > /dev/null
	@yes | docker network prune > /dev/null

defaults:
	@echo "${PURPLE}Username : ${NC}${POSTGRES_USER}"
	@echo "${PURPLE}Password : ${NC}${POSTGRES_PASSWORD}"
