#!/usr/bin/env bash

SCRIPTLOC="$(readlink -f "${BASH_SOURCE[0]%/*}")"
# for gpg's keys
export HOME="${SCRIPTLOC}/misc"

cd /export/scratch/home/gentoo/snapshots

TODAY=$(date +%s)
YESTERDAY=$((TODAY - 86400))

RSYNCTREE=${PWD%/*}/prefix-rsync-tree
SNAME=${PWD}/portage-$(date +%Y%m%d -d @${YESTERDAY}).tar
TMPDIR=${PWD%/*}/tmp-prefix-snapshot

# clean up
find . -maxdepth 2 -daystart -ctime +4 -type f | xargs --no-run-if-empty rm

rm -Rf ${TMPDIR}
mkdir -p ${TMPDIR}

# quickly take a snapshot, such that we get a consistent image
pushd ${RSYNCTREE} > /dev/null
tar -cf ${SNAME} *
popd > /dev/null

# now revamp it such that it's in a directory "portage"
pushd ${TMPDIR} > /dev/null
mkdir portage
tar -xf ${SNAME} -C portage/
tar -cf ${SNAME} portage/
popd > /dev/null

rm -Rf ${TMPDIR}

# be nice, and this machine only has one CPU (so can't parallelise)
nice -n19 bzip2 -c -9 ${SNAME} > ${SNAME}.bz2
nice -n19 xz -c -9 ${SNAME} > ${SNAME}.xz
nice -n19 gzip -c -9 ${SNAME} > ${SNAME}.gz

# generate accompanying meta files
md5sum ${SNAME##*/}      > ${SNAME}.xz.umd5sum
md5sum ${SNAME##*/}.xz   > ${SNAME}.xz.md5sum
md5sum ${SNAME##*/}      > ${SNAME}.bz2.umd5sum
md5sum ${SNAME##*/}.bz2  > ${SNAME}.bz2.md5sum
md5sum ${SNAME##*/}      > ${SNAME}.gz.umd5sum
md5sum ${SNAME##*/}.bz2  > ${SNAME}.gz.md5sum
# gpg is really stupid, or I am too stupid to find the right option
gpg --batch --no-tty --passphrase-fd 0 --default-key C6317B3C --detach-sign --armor -o ${SNAME}.xz.gpgsig ${SNAME}.xz < ${SCRIPTLOC}/autosigner.pwd
gpg --batch --no-tty --passphrase-fd 0 --default-key C6317B3C --detach-sign --armor -o ${SNAME}.bz2.gpgsig ${SNAME}.bz2 < ${SCRIPTLOC}/autosigner.pwd
gpg --batch --no-tty --passphrase-fd 0 --default-key C6317B3C --detach-sign --armor -o ${SNAME}.gz.gpgsig ${SNAME}.gz < ${SCRIPTLOC}/autosigner.pwd

# we no longer need the tar
rm ${SNAME}

# make convenience symlinks
for f in {xz,bz2,gz}{,.gpgsig,.md5sum,.umd5sum} ; do
	rm portage-latest.tar.$f
	ln -s ${SNAME##*/}.$f portage-latest.tar.$f
done

# darkside's delta code

# FAILS and nobody cares!

#YESTERDAY=$(date +%Y%m%d -d @${YESTERDAY})
#TODAY=$(date +%Y%m%d -d @${TODAY})
#cp portage-{${YESTERDAY},${TODAY}}.tar.bz2 /dev/shm/
#SNAP_DIR=${PWD}
#
#cd /dev/shm
#bunzip2 portage*
#
#differ -f bdelta portage-{${YESTERDAY},${TODAY}}.tar \
#    ${SNAP_DIR}/deltas/snapshot-${YESTERDAY}-${TODAY}.patch
#
#bzip2 "${SNAP_DIR}/deltas/snapshot-${YESTERDAY}-${TODAY}.patch"
#
#rm -f portage* snapshot*

# FAILS and nobody cares
