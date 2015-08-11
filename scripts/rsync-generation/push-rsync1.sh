#!/usr/bin/env bash

TRGDIR="rsync1.domain::rsync-push_module"
LOCALDIR="/path/to/master-rsync-tree"

# figure out what's currently the active rsync1 mirror
#active=$(ssh $TRGHOST "readlink $TRGDIR/rsync1")
#echo "($(date +"%F %R")) current active snapshot on rsync1: ${active}"

#case $active in
#	rsync1a)  target=rsync1b ;;
#	rsync1b)  target=rsync1a ;;
#	*)
#		echo "don't know what the active rsync1 mirror is: '$active'" > /dev/stderr
#		exit 1
#	;;
#esac
echo "($(date +"%F %R")) will refresh and activate snapshot: ${target}"

# synchronise the target
rsync -va --delete "${LOCALDIR}"/ ${TRGDIR}/ > /var/tmp/rsync-updates.log || exit 1

# switch the active rsync1 mirror
echo "($(date +"%F %R")) rsync done, switching target now"
#ssh $TRGHOST "cd ${TRGDIR} && rm rsync1 && ln -s ${target} rsync1"
