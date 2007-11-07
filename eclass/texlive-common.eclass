# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/texlive-common.eclass,v 1.3 2007/11/06 23:34:43 aballier Exp $

#
# Original Author: Alexis Ballier <aballier@gentoo.org>
# Purpose: Provide various functions used by both texlive-core and texlive
# modules.
# Note that this eclass *must* not assume the presence of any standard tex tool
#


TEXMF_PATH=/usr/share/texmf
TEXMF_DIST_PATH=/usr/share/texmf-dist
TEXMF_VAR_PATH=/var/lib/texmf

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

# Mimic the install_link function of texlinks
# Should have the same behavior as the one in /usr/bin/texlinks
# except that it is under the control of the package manager
# Note that $1 corresponds to $src and $2 to $dest in this function
# ( Arguments are switched because texlinks main function sends them switched )
# This function should not be called from an ebuild, prefer etexlinks that will
# also do the fmtutil file parsing.

texlive-common_do_symlinks() {
	while [ $# != 0 ]; do
		case $1 in
			cont-??|metafun|mptopdf)
				elog "Symlink $1 skipped (special case)"
				;;
			*)
				if [ $1 = $2 ];
				then
					elog "Symlink $1 -> $2 skipped"
				elif [ -e "${ED}/usr/bin/$1" ];
				then
					elog "Symlink $1 skipped (file exists)"
				else
					elog "Making symlink from $1 to $2"
					dosym $2 /usr/bin/$1
				fi
				;;
		esac
		shift; shift;
	done
}

# Mimic texlinks on a fmtutil format file
# $1 has to be a fmtutil format file like fmtutil.cnf
# etexlinks foo will install the symlinks that texlinks --cnffile foo would have
# created. We cannot use texlinks with portage as it is not DESTDIR aware.
# (It would not fail but will not create the symlinks if the target is not in
# the same dir as the source)
# Also, as this eclass must not depend on a tex distribution to be installed we
# cannot use texlinks from here.

etexlinks() {
	# Install symlinks from formats to engines
	texlive-common_do_symlinks $(sed '/^[      ]*#/d; /^[      ]*$/d' "$1" | awk '{print $1, $2}')
}

