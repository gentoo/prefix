# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.2.3.ebuild,v 1.6 2009/04/06 19:19:36 bluebird Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xtrans library"

KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	PATCHES=(
		"${FILESDIR}"/${PN}-1.2.1-winnt.patch
		"${FILESDIR}"/${P}-winnt-ipv6.patch
	)

	x-modular_src_unpack
}
