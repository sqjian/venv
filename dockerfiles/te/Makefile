all: run

up:
	docker compose -f ./te.compose.yml up --progress plain workspace --force-recreate --always-recreate-deps

down:
	docker compose -f ./te.compose.yml --progress plain down --remove-orphans --volumes

build:
	docker compose -f ./te.compose.yml --progress plain build workspace --no-cache

run:
	docker compose -f te.compose.yml --progress plain run -i --rm --build --no-deps --service-ports -u root --entrypoint 'bash -lc' workspace 'exec fish'