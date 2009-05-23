# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/confuse/confuse-2.6-r3.ebuild,v 1.6 2008/12/17 22:09:10 maekke Exp $

inherit autotools

inherit eutils

DESCRIPTION="a configuration file parser library"
HOMEPAGE="http://www.nongnu.org/confuse/"
SRC_URI="http://bzero.se/confuse/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="nls"

DEPEND="sys-devel/flex
	sys-devel/libtool
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# bug #236347
	epatch "${FILESDIR}"/${P}-O0.patch
	# bug 239020
	epatch "${FILESDIR}"/${P}-solaris.patch
	# drop -Werror, bug #208095
	sed -i -e 's/-Werror//' */Makefile.* || die

	eautoreconf # need new libtool for interix
}

src_compile() {
	econf --enable-shared || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	doman doc/man/man3/*.3
	dodoc AUTHORS NEWS README
	dohtml doc/html/* || die
}
