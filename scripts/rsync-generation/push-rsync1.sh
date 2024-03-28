#!/usr/bin/env bash

TRGDIR="/path/to/rsync0-prefix-tree"
LOCALDIR="/path/to/master-rsync-tree"

echo "($(date +"%F %R")) will refresh snapshot"

# synchronise the target
rsync -vca --delete --exclude=snapshots/ \
	"${LOCALDIR}"/ ${TRGDIR}/ > /var/tmp/rsync-updates.log || exit 1

PUBLICDIR=
case $(hostname) in
    disabled)
        PUBLICDIR="somehost::gentoo-portage-prefix-push"
        ;;
esac
# switch the active rsync1 mirror
if [[ -n ${PUBLICDIR} ]] ; then
    rsync -vca --delete "${TRGDIR}"/ "${PUBLICDIR}"/
fi

echo "($(date +"%F %R")) rsync done"
