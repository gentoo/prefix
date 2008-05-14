#!/usr/bin/env bash

export PTREEDIR="$(pwd -P)"
for d in profiles/base profiles/desc profiles/updates eclass licenses *-*/* virtual/* ; do
	pushd ${d} > /dev/null
	if [[ -f eupdate.noupdate ]] || [[ -f eupdate.skip ]] ; then
		echo "S skipping $d"
	else
		eupdate >& /var/tmp/eupdate.out.$$
		ret=$?
		case $ret in
			-1)
				echo "C $d has errors"
				cp /var/tmp/eupdate.out.$$ eupdate.errors
			;;
			1)
				echo "U $d has updates"
				cp /var/tmp/eupdate.out.$$ eupdate.updates
			;;
		esac
		rm /var/tmp/eupdate.out.$$
	fi
	popd > /dev/null
done
