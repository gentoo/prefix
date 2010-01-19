# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xclock/xclock-1.0.4.ebuild,v 1.8 2010/01/18 19:08:56 armin76 Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="analog / digital clock for X"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXrender
	x11-libs/libXft
	x11-libs/libxkbfile
	x11-libs/libXaw"
DEPEND=""

pkg_setup() {
	if [[ ${CHOST} == *-winnt* ]]; then
		append-flags -xc++ -DNO_I18N

		PATCHES=(
			"${FILESDIR}"/${PN}-1.0.3-winnt.patch
		)
	fi
}

