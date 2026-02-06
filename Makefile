all:
	make -f compose.mk run

build:
	make -f compose.mk build

git:
	git add -A
	git commit -m "update"