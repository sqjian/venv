all:
	docker rm -f ubuntu || true
	docker run --name=ubuntu -it --rm ubuntu:18.04 bash

push:
	git add .
	git commit -m "update"
	git push