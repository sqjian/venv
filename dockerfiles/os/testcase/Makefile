all: run

up:
	docker compose -f ./testcase.yaml up --progress plain workspace --force-recreate --always-recreate-deps

down:
	docker compose -f ./testcase.yaml --progress plain down --remove-orphans --volumes

build:
	docker compose -f ./testcase.yaml --progress plain build workspace

run:
	docker compose -f testcase.yaml --progress plain run -i --rm --build --no-deps --service-ports -u root --entrypoint 'bash -lc' workspace 'exec fish'