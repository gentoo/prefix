#!/usr/bin/env bash

[[ -z $1 ]] && exit 2

dir=${1%/eupdate.updates}
dir=${dir#./}

# for edit shells
export PTREEDIR=$(pwd -P)

cd "$dir"
echo
echo "==================================================================="
echo "package $dir"
echo "-------------------------------------------------------------------"
cat eupdate.updates

# try to figure out if there were real changes
diffs=$(svn diff --diff-cmd diff -x -u0 $(find . -maxdepth 1 | sed -e 's|^\./||' -e '/^ChangeLog/d' -e '/^metadata.xml$/d' -e '/^Manifest$/d' -e '/^eupdate.updates$/d' -e '/\.svn\(\/.*\)\?$/d' -e '/^\.$/d') 2>&1 | sed -e '/^Index: /d' -e '/^======/d' -e '/^--- /d' -e '/^+++ /d' -e '/^@@ .* @@$/d' -e '/^[-+]# $Header: /d' -e '/^[-+]# Copyright 1999-20/d')
if [[ -z ${diffs} ]] ; then
	# "trivial" changes, commit straight away
	echo ">>> Trivial changes detected, committing right away"
	echo "Full auto-sync (trivial changes)" > eupdate.msg
	${PTREEDIR}/scripts/treesync/rqcommit.sh "${dir}" &
	exit 0
fi

# else, do an interactive session
echo "Semi auto-sync" > eupdate.msg
echo "-------------------------------------------------------------------"
thinking=$(date +%s)
while [[ -z $do_update ]]; do
	echo -n "commit this update? [y/n/e] "
	read do_update
	case $do_update in
		y|Y|yes)
			etime=$(date +%s)
			if [[ -z ${didedit} ]] ; then
				echo "(reviewed in $((etime - thinking)) seconds)" >> eupdate.msg
			else
				etime=$((etime - thinking))
				echo "(manually editted for $((etime / 60))m $((etime % 60))s)" >> eupdate.msg
			fi
			break
		;;
		n|N|no)
			unset do_update
			mv eupdate.updates eupdate.noupdate
			break
		;;
		e|edit)
			unset do_update
			$SHELL
			svn status --no-ignore
			didedit=yes
		;;
		*)
			echo "response $do_update not understood"
			unset do_update
		;;
	esac
done

[[ -n $do_update ]] && ${PTREEDIR}/scripts/treesync/rqcommit.sh "${dir}" &
