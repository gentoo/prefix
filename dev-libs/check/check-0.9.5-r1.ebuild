# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/check/check-0.9.5-r1.ebuild,v 1.9 2009/04/29 11:33:52 armin76 Exp $

inherit eutils autotools

DESCRIPTION="A unit test framework for C"
HOMEPAGE="http://sourceforge.net/projects/check/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-autotools.patch
	epatch "${FILESDIR}"/${P}-AM_PATH_CHECK.patch
	epatch "${FILESDIR}"/${P}-setup-stats.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die
	mv "${ED}"/usr/share/doc/{${PN},${PF}} || die
}
