# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xkbcomp/xkbcomp-1.0.3.ebuild,v 1.4 2007/04/29 06:09:34 ticho Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular multilib

DESCRIPTION="compile XKB keyboard description"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND="x11-libs/libX11
	x11-libs/libxkbfile"
DEPEND="${RDEPEND}"

src_install() {
	x-modular_src_install

	dodir usr/share/X11/xkb
	dosym ../../../bin/xkbcomp /usr/share/X11/xkb/xkbcomp

	# (#122214) We should create this directory here, since xkeyboard-config
	# and any other set of layouts will symlink to it.
	dodir /var/lib/xkb
	keepdir /var/lib/xkb
}
