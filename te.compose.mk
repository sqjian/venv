all: run

up:
	docker compose -f te.compose.yaml --progress plain up workspace --force-recreate --always-recreate-deps

down:
	docker compose -f te.compose.yaml --progress plain down --volumes

build:
	docker compose -f te.compose.yaml --progress plain build workspace --no-cache

run:
	docker compose -f te.compose.yaml --progress auto run -it --rm --build --no-deps --service-ports -u root --entrypoint 'fish -l' workspace