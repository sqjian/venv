all: run

up:
	docker compose -f compose.yaml up workspace --force-recreate --always-recreate-deps

down:
	docker compose -f compose.yaml down --volumes

build:
	docker compose -f compose.yaml build --progress plain workspace

run:
	docker compose -f compose.yaml run -i --rm --build --no-deps --service-ports -u root --entrypoint 'bash -l' workspace