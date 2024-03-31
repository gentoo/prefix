#!/usr/bin/env bash

SCRIPTLOC="$(readlink -f "${BASH_SOURCE[0]%/*}")"
# for gpg's keys
export HOME="${SCRIPTLOC}/misc"

cd /export/gentoo-rsync/rsync0-prefix-tree/snapshots || exit 1

TODAY=$(date +%s)
YESTERDAY=$((TODAY - 86400))

RSYNCTREE=${PWD%/*}
SNAME=${PWD}/portage-$(date +%Y%m%d -d @${YESTERDAY}).tar
TMPDIR=${PWD}/tmp-prefix-snapshot

# clean up
find . -maxdepth 2 -daystart -ctime +4 -type f -exec rm '{}' +

# pull in active snapshot
BOOTSTRAP_SNAPSHOT=$( \
	grep -A1 MKSNAPSHOT-ANCHOR "${RSYNCTREE}"/scripts/bootstrap-prefix.sh | \
	sed -n 's/^.*PV="\([0-9]\+\)"\s*$/portage-\1.tar.bz2/p' \
)
if [[ ! -s "${BOOTSTRAP_SNAPSHOT}" ]] ; then
	curl -s -L "https://distfiles.prefix.bitzolder.nl/prefix/distfiles/${BOOTSTRAP_SNAPSHOT}" > "${BOOTSTRAP_SNAPSHOT}"
fi

rm -Rf "${TMPDIR}"
mkdir -p "${TMPDIR}"

# quickly take a snapshot, such that we get a consistent image
pushd "${RSYNCTREE}" > /dev/null || exit 1
tar -cf "${SNAME}" --exclude=snapshots -- * || exit 1
popd > /dev/null || exit 1

# now revamp it such that it's in a directory "portage"
rm -Rf "${TMPDIR}"
mkdir -p "${TMPDIR}"
pushd "${TMPDIR}" > /dev/null || exit 1
mkdir portage
tar -xf "${SNAME}" -C portage/
tar --numeric-owner --format=posix --hard-dereference -cf "${SNAME}" portage/
popd > /dev/null || exit 1

rm -Rf "${TMPDIR}"

COMPRS=(
	"gz:gzip -c -9"
	"bz2:bzip2 -c -9"
	"xz:xz -c -9"
	"lz:lzip -c -9"
	"zst:zstd -c -k -f -9"
)

# produce compressed variants, use as much cpu as left on the system, do
# all in parallel
for compr in "${COMPRS[@]}" ; do
	read -r -a args <<< "${compr#*:}"
	nice -n19 "${args[@]}" "${SNAME}" > "${SNAME}.${compr%%:*}" &
done
wait

# generate accompanying meta files
for compr in "${COMPRS[@]}" ; do
	compr=${compr%%:*}
	md5sum "${SNAME##*/}"          > "${SNAME}.${compr}.umd5sum"
	md5sum "${SNAME##*/}.${compr}" > "${SNAME}.${compr}.md5sum"
done

# create GPG detached signature, use passphrase-fd to pass password
gpgopts=(
	"--quiet"
	"--batch"
	"--no-tty"
	"--passphrase-fd" 0
	"--pinentry-mode" "loopback"
	"--default-key" "C6317B3C"
	"--detach-sign"
	"--armor"
)
for compr in "${COMPRS[@]}" ; do
	compr=${compr%%:*}
	gpg "${gpgopts[@]}" -o "${SNAME}.${compr}.gpgsig" "${SNAME}.${compr}" \
		< "${SCRIPTLOC}"/autosigner.pwd
done

# we no longer need the (original/uncompressed) tar
rm "${SNAME}"

# make convenience symlinks
for compr in "${COMPRS[@]}" ; do
	compr=${compr%%:*}
	for f in "${compr}"{,.gpgsig,.md5sum,.umd5sum} ; do
		rm "portage-latest.tar.${f}"
		ln -s "${SNAME##*/}.${f}" "portage-latest.tar.${f}"
	done
done
