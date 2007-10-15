# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/texlive-common.eclass,v 1.1 2007/10/14 07:44:09 aballier Exp $

#
# Original Author: Alexis Ballier <aballier@gentoo.org>
# Purpose: Provide various functions used by both texlive-core and texlive
# modules.
# Note that this eclass *must* not assume the presence of any standard tex tool
#


TEXMF_PATH=/usr/share/texmf
TEXMF_DIST_PATH=/usr/share/texmf-dist
TEXMF_VAR_PATH=/usr/share/texmf-var

# Has to be called in src_install after having installed the files in ${D}
# This function will move the relevant files to /etc/texmf and symling them
# from their original location. This is to allow easy update of texlive's
# configuration

texlive-common_handle_config_files() {
	# Handle config files properly
	cd "${ED}${TEXMF_PATH}"
	for f in $(find . -name '*.cnf' -o -name '*.cfg' -type f | sed -e "s:\./::g") ; do
		if [ "${f#*config}" != "${f}" ] ; then
			continue
		fi
		dodir /etc/texmf/$(dirname ${f}).d
		mv "${ED}/${TEXMF_PATH}/${f}" "${ED}/etc/texmf/$(dirname ${f}).d" || die "mv ${f} failed."
		dosym /etc/texmf/$(dirname ${f}).d/$(basename ${f}) ${TEXMF_PATH}/${f}
	done
}


# Return if a file is present in the texmf tree
# Call it from the directory containing texmf and texmf-dist

texlive-common_is_file_present_in_texmf() {
	local mark="${T}/$1.found"
	find texmf -name $1 -exec touch "${mark}" \;
	find texmf-dist -name $1 -exec touch "${mark}" \;
	[ -f "${mark}" ]
}
