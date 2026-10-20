all: run

up:
	docker compose -f docker-compose.yml --progress plain up workspace --force-recreate --always-recreate-deps

down:
	docker compose -f docker-compose.yml --progress plain down --volumes

build:
	docker compose -f docker-compose.yml --progress plain build workspace

run:
	docker compose -f docker-compose.yml --progress auto run -it --rm --build --no-deps --service-ports -u root --entrypoint 'fish -l' workspace