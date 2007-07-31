#!/usr/bin/env bash

export PTREEDIR="$(pwd -P)"
for d in *-*/* virtual/* eclass licenses profiles/base profiles/updates ; do
	pushd ${d} > /dev/null
	if [[ -f eupdate.noupdate ]] || [[ -f eupdate.skip ]] ; then
		echo "skipping $d"
	else
		eupdate >& /var/tmp/eupdate.out.$$
		ret=$?
		case $ret in
			-1)
				echo "$d has errors"
				cp /var/tmp/eupdate.out.$$ eupdate.errors
			;;
			1)
				echo "$d has updates"
				cp /var/tmp/eupdate.out.$$ eupdate.updates
			;;
		esac
		rm /var/tmp/eupdate.out.$$
	fi
	popd > /dev/null
done
