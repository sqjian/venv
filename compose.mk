all: run

up:
	docker compose -f compose.yaml --progress plain up workspace --force-recreate --always-recreate-deps

down:
	docker compose -f compose.yaml --progress plain down --volumes

build:
	docker compose -f compose.yaml --progress plain build workspace

run:
	docker compose -f compose.yaml --progress plain run -i --rm --build --no-deps --service-ports -u root --entrypoint 'bash -l' workspace 'exec fish'