# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# On hpux, binary files (executables, shared libraries) in use
# cannot be replaced during merge.
# But it is possible to rename them and remove lateron when they are
# not used any more by any running process.
#
# This is a workaround for portage bug#199868,
# and should be dropped once portage does sth. like this itself.

post_pkg_preinst() {
	removedlist="${EROOT}var/lib/portage/files2bremoved"
	rm -f "${removedlist}".new

	if [[ -r ${removedlist} ]]; then
		rm -f "${removedlist}".old
	fi
	# restore in case of system fault
	if [[ -r ${removedlist}.old ]]; then
		mv "${removedlist}"{.old,}
	fi

	touch "${removedlist}"{,.new} # ensure they exist

	while read rmstem; do
		# try to remove previously recorded files
		for f in "${ROOT}${rmstem}"*; do
			echo "trying to remove old busy text file ${f}"
			rm -f "${f}"
		done
		# but keep it in list if still exists
		for f in "${ROOT}${rmstem}"*; do
			[[ -f ${f} ]] && echo "${rmstem}" >> "${removedlist}".new
			break
		done
	done < "${removedlist}"

	# update the list
	mv "${removedlist}"{,.old}
	mv "${removedlist}"{.new,}
	rm "${removedlist}".old
	
	# now go for current package
	cd "${D}"
	find ".${EPREFIX}" -type f | xargs -r /usr/bin/file | grep 'object file' | while read f t
	do
		f=${f#./} # find prints: "./path/to/file"
		f=${f%:} # file prints: "file-argument: type-of-file"
		test -r "${ROOT}${f}" || continue
		rmstem="${f}.removedbyportage"
		# keep list of old busy text files unique
		grep "^${rmstem}$" "${removedlist}" >/dev/null \
		|| echo "${rmstem}" >> "${removedlist}"
		n=0
		while [[ ${n} -lt 100 && -f "${ROOT}${rmstem}${n}" ]]; do
			n=$((n=n+1))
		done

		if [[ ${n} -ge 100 ]]; then
			echo "too many (>=100) old text files busy of '${ROOT}${f}'" >&2
			exit 1
		fi
		echo "backing up text file ${ROOT}${f} (${n})"
		mv "${ROOT}${f}" "${ROOT}${rmstem}${n}" || exit 1
		# preserve original binary (required for bash fex)
		cp -p "${ROOT}${rmstem}${n}" "${ROOT}${f}" || exit 1
	done
}
