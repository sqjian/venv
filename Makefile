all: force_push

force_push:
	@echo "Force pushing to remote repository..."
	git add -A
	git commit --amend --no-edit
	git push -f origin main
	@echo "Force push completed."

rebuild:
	vagrant destroy -f && vagrant up && vagrant ssh