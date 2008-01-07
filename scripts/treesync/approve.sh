#!/usr/bin/env bash

[[ -z $1 ]] && exit 2

dir=${1%/eupdate.updates}
dir=${dir#./}

# for edit shells
export PTREEDIR="$(pwd -P)"

cd $dir
echo
echo "==================================================================="
echo "package $dir"
echo "-------------------------------------------------------------------"
cat eupdate.updates
echo "-------------------------------------------------------------------"
while [[ -z $do_update ]]; do
	echo -n "commit this update? [y/n/e] "
	read do_update
	case $do_update in
		y|Y|yes)
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
			svn status
		;;
		*)
			echo "response $do_update not understood"
			unset do_update
		;;
	esac
done

if [[ -n $do_update ]]; then
	ts=$(stat --format="%y" eupdate.updates)
	rm eupdate.updates
	( ecleankw > /dev/null && ekeyword *.ebuild > /dev/null &&  repoman commit -m "Semi-auto sync $dir ($ts)" >& /var/tmp/repoman.commit.$$ && rm /var/tmp/repoman.commit.$$ || mv /var/tmp/repoman.commit.$$ repoman.commit.failed ) &
fi
