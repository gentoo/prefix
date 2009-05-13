# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# never use /bin/sh as CONFIG_SHELL on AIX: it works, but is way to slow.
export CONFIG_SHELL=${BASH}

# Portage cannot merge shared objects inside archive libraries on AIX (yet).
# So we need to hack around by unpacking the archive libraries, let portage
# merge/unmerge the archive library members as normal files, and recreate the
# archive libraries after merge/unmerge.

aixdll_find_unprepared() {
	find "$1" -type f -name 'lib*.a' -print
}

aixdll_find_prepared() {
	find "$1" -type d -name 'lib*.a.d' -print
}

aixdll_prepare_for_merge() {
	local liba=$1
	local libad=${liba}.d
	mkdir "${libad}" || die "Cannot create ${libad}"
	pushd "${libad}" >/dev/null || die "Cannot cd to ${libad}"
	/usr/ccs/bin/ar -x "${liba}" || die "Cannot un-ar ${liba}"
	popd >/dev/null || die "Cannot cd back from ${libad}"
	true
}

aixdll_is_prepared() {
	local what=$1
	[[ ${what##*/} == lib*.a.d ]]
}

aixdll_unprepare_from_merge() {
	aixdll_is_prepared "${1}" || return 0
	local liba libad
	libad=${1}
	liba=${libad%.d}

	if [[ -d ${libad} ]]; then
		pushd "${libad}" >/dev/null || die "Cannot cd to ${libad}"
		rm -f "./${liba##*/}.new" || die "Cannot remove ${liba##*/}.new"
		/usr/ccs/bin/ar -coqszvl -X 32_64 "./${liba##*/}.new" ./* || die "Cannot recreate ${liba}"
		mv -f "./${liba##*/}.new" "${liba}" || die "Cannot move ${liba##*/}.new to ${liba}"
		popd >/dev/null || die "Cannot cd back from ${libad}"
	elif [[ -f ${liba} ]]; then
		rm -f "${liba}" || die "Cannot prune ${liba}"
	fi
	true
}

post_src_install() {
	local liba
	einfo "Preparing AIX libraries for merge..."
	pushd "${D}" >/dev/null || die "Cannot cd to ${D}"
	for liba in $(aixdll_find_unprepared .); do
		/bin/file "${liba}" | /bin/grep ': archive' >/dev/null || return 0
		liba=${liba#./}
		einfo "preparing ${liba}"
		aixdll_prepare_for_merge "${D}${liba}"
		rm -f "${D}${liba}" || die "Cannot prune ${liba}"
		eend 0
	done
	popd >/dev/null || die "Cannot cd back from ${D}"
}

pre_pkg_postinst() {
	local libad save_IFS content
	einfo "Preparing AIX libraries for unmerge..."
	pushd "${D}" >/dev/null || die "Cannot cd to ${D}"
	for libad in $(aixdll_find_prepared .); do
		libad=${libad#./}
		aixdll_is_prepared "${ROOT}${libad}" || continue
		einfo "unpreparing ${libad}"
		aixdll_unprepare_from_merge "${ROOT}${libad}"
		eend 0
	done
	popd >/dev/null || die "Cannot cd back from ${D}"
}

pre_pkg_postrm() {
	local libad save_IFS content
	einfo "Preparing AIX libraries for unmerge..."
	pushd "${ROOT}" >/dev/null || die "Cannot cd to ${ROOT}"
	save_IFS=$IFS
	IFS='
';
	local MY_PR=${PR}
	[[ ${MY_PR} == r0 ]] && MY_PR=
	local -a contents=($(<"${EPREFIX}/var/db/pkg/${CATEGORY}/${P}${MY_PR:+-}${MY_PR}/CONTENTS"));
	IFS=$save_IFS
	local -a cont
	for content in "${contents[@]}"; do
		cont=(${content})
		libad=${cont[1]}
		libad=${libad#/}
		aixdll_is_prepared "${ROOT}${libad}" || continue
		einfo "unpreparing ${libad}"
		aixdll_unprepare_from_merge "${ROOT}${libad}"
		eend 0
	done
	popd >/dev/null || die "Cannot cd back from ${ROOT}"
}
