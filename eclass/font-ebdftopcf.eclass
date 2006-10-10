# Copyright 2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/font-ebdftopcf.eclass,v 1.4 2006/04/02 00:24:51 robbat2 Exp $

# Author: Robin H. Johnson <robbat2@gentoo.org>

# font-ebdftopcf.eclass
# Eclass to make PCF font generator from BDF uniform and optimal
# The manpage for this eclass is in media-gfx/ebdftopcf.

# Variable declarations
DEPEND="media-gfx/ebdftopcf"
RDEPEND=""

#
# Public functions
#
ebdftopcf() {
	local bdffiles
	bdffiles="$@"
	[ -z "$bdffiles" ] && die "No BDF files specified."
	emake -f /usr/share/ebdftopcf/Makefile.ebdftopcf \
		BDFFILES="${bdffiles}" \
		BDFTOPCF_PARAMS="${BDFTOPCF_PARAMS}" \
		|| die "Failed to build PCF files"
}

#
# Public inheritable functions
#
font-ebdftopcf_src_compile() {
	[ -z "${BDFFILES}" ] && BDFFILES="$(find . -name '*.bdf')"
	ebdftopcf ${BDFFILES}
}

EXPORT_FUNCTIONS src_compile
