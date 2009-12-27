# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xproto/xproto-7.0.16.ebuild,v 1.4 2009/12/15 19:50:53 ranger Exp $

inherit x-modular

DESCRIPTION="X.Org xproto protocol headers"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xorg/proto/x11proto"

KEYWORDS="~ppc-aix ~x64-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

pkg_setup() {
	[[ ${CHOST} == *-winnt* ]] &&
		PATCHES=( "${FILESDIR}"/${P}-winnt.patch )
}
