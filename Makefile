all: build

run:
	make -f te.compose.mk run

build:
	make -f te.compose.mk build

git:
	git add -A
	git commit -m "update"