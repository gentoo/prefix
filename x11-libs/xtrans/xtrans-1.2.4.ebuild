# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.2.4.ebuild,v 1.1 2009/09/28 10:42:37 remi Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xtrans library"
KEYWORDS="~ppc-aix ~x64-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	PATCHES=(
		"${FILESDIR}"/${PN}-1.2.1-winnt.patch
		"${FILESDIR}"/${PN}-1.2.3-winnt-ipv6.patch
	)

	x-modular_src_unpack
}
