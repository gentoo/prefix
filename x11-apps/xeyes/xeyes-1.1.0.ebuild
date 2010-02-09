# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xeyes/xeyes-1.1.0.ebuild,v 1.3 2010/02/08 15:43:18 fauli Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org xeyes application"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-winnt"
IUSE=""
RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext
	x11-libs/libXmu
	x11-libs/libXrender"
DEPEND="${RDEPEND}"

CONFIGURE_OPTIONS="--with-xrender"

pkg_setup() {
	if [[ ${CHOST} == *-winnt* ]]; then
		PATCHES=( "${FILESDIR}"/${PN}-1.0.1-winnt.patch)
		append-flags -xc++
	fi
}
