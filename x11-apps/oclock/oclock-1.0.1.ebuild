# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/oclock/oclock-1.0.1.ebuild,v 1.8 2009/05/05 07:35:32 fauli Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="round X clock"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-winnt"
IUSE=""
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
