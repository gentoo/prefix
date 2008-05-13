# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/confuse/confuse-2.6.ebuild,v 1.8 2008/05/12 16:22:29 maekke Exp $

EAPI="prefix"

inherit autotools flag-o-matic

DESCRIPTION="a configuration file parser library"
HOMEPAGE="http://www.nongnu.org/confuse/"
SRC_URI="http://bzero.se/confuse/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE="nls"

DEPEND="sys-devel/libtool
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	econf \
		--enable-shared \
		$(use_enable nls) || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	doman doc/man/man3/*.3
	dodoc AUTHORS NEWS README
	dohtml doc/html/* || die
}
