# Makefile for rsync

push-dry:
	rsync -anv . boltzmann:~/bin/Version5_ev1738/Dragon/msca/ \
	--delete --exclude-from=.rsyncignore

push:
	rsync -avzP . boltzmann:~/bin/Version5_ev1738/Dragon/msca/ \
	--exclude-from=.rsyncignore

pull-dry:
	rsync -av boltzmann:~/bin/Version5_ev1738/Dragon/msca/ . \
	--delete --exclude-from=.rsyncignore --dry-run

pull:
	rsync -avzP boltzmann:~/bin/Version5_ev1738/Dragon/msca/ . \
	--exclude-from=.rsyncignore

.PHONY: push-dry push pull-dry pull
