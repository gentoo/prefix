# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/oclock/oclock-1.0.1.ebuild,v 1.7 2007/11/24 15:29:15 armin76 Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="round X clock"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-winnt"

RDEPEND="x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXext"
DEPEND="${RDEPEND}"

pkg_setup() {
	if [[ ${CHOST} == *-winnt* ]]; then
		append-flags -xc++

		PATCHES=(
			"${FILESDIR}"/${P}-winnt.patch
		)
	fi
}
