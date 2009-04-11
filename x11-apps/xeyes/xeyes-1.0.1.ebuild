# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xeyes/xeyes-1.0.1.ebuild,v 1.4 2006/09/18 11:54:09 dberkholz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org xeyes application"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-winnt"
RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext
	x11-libs/libXmu"
DEPEND="${RDEPEND}"

pkg_setup() {
	if [[ ${CHOST} == *-winnt* ]]; then
		PATCHES=(
			"${FILESDIR}"/${P}-winnt.patch
		)

		append-flags -xc++
	fi
}
