# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/passook/passook-1.0.0.ebuild,v 1.22 2008/01/26 10:03:28 grobian Exp $

EAPI="prefix"

inherit eutils

S=${WORKDIR}
DESCRIPTION="Password generator capable of generating pronounceable and/or secure passwords."
SRC_URI="http://mackers.com/projects/passook/${PN}.tar.gz"
HOMEPAGE="http://mackers.com/misc/scripts/passook/"
IUSE=""

SLOT="0"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND="dev-lang/perl
	sys-apps/grep
	sys-apps/miscfiles"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/passook.diff
	epatch "${FILESDIR}"/passook-prefix.patch
	eprefixify passook
}

src_install() {
	dobin passook
	dodoc README passook.cgi
}
