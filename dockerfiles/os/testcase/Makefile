all: run

up:
	docker compose -f ./testcase.yaml up testcase --force-recreate --always-recreate-deps

down:
	docker compose -f ./testcase.yaml down --remove-orphans --volumes

build:
	docker compose -f ./testcase.yaml build --progress plain testcase

run:
	docker compose -f testcase.yaml run -i --rm --build --no-deps --service-ports -u root --entrypoint 'bash -lc' testcase 'exec bash'