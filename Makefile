all: build

run:
	make -f dummy.compose.mk run

build:
	make -f dummy.compose.mk build

git:
	git add -A
	git commit -m "update"