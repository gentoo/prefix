# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xorg-cf-files/xorg-cf-files-1.0.2.ebuild,v 1.8 2006/09/03 06:20:40 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="Old Imake-related build files"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND=""
DEPEND=""

src_install() {
	x-modular_src_install
	echo "#define ManDirectoryRoot ${EPREFIX}/usr/share/man" >> ${ED}/usr/$(get_libdir)/X11/config/host.def
}
