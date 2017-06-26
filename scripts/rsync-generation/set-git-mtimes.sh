#!/usr/bin/env bash

git ls-files | \
while read fname ; do
	touch -m -t $(git log --pretty=format:'%cd' -n 1 --date=format-local:'%Y%m%d%H%M.%S' -- "${fname}") "${fname}"
done
