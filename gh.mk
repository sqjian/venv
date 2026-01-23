all: cancel-run-in-progress

cancel-run-in-progress:
	gh run ls -s in_progress --json databaseId -q .[].databaseId|xargs -n1 gh run cancel