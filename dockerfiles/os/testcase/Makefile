all: run

up:
	docker compose -f ./testcase.yaml up workspace --force-recreate --always-recreate-deps

down:
	docker compose -f ./testcase.yaml down --remove-orphans --volumes

build:
	docker compose -f ./testcase.yaml build --progress plain workspace

run:
	docker compose -f testcase.yaml run -i --rm --build --no-deps --service-ports -u root --entrypoint 'bash -lc' workspace 'exec bash'