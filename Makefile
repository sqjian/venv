all: rebuild

rebuild:
	vagrant destroy -f && vagrant up && vagrant ssh