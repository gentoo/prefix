# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/gnutls-2.2.0.ebuild,v 1.3 2007/12/19 19:15:05 alonbl Exp $

EAPI="prefix"

inherit libtool autotools

DESCRIPTION="A TLS 1.0 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"
SRC_URI="http://josefsson.org/gnutls/releases/${P}.tar.bz2"

# GPL-3 for the gnutls-extras library and LGPL for the gnutls library.
LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="zlib lzo doc nls guile"

RDEPEND="dev-libs/libgpg-error
	>=dev-libs/libgcrypt-1.2.4
	>=dev-libs/libtasn1-0.3.4
	>=app-crypt/opencdk-0.6.4
	nls? ( virtual/libintl )
	guile? ( dev-scheme/guile )
	zlib? ( >=sys-libs/zlib-1.1 )
	lzo? ( >=dev-libs/lzo-2 )"
DEPEND="${RDEPEND}
	sys-devel/libtool
	doc? ( dev-util/gtk-doc )
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize # for sane .so versioning on FreeBSD

	epatch "${FILESDIR}/${P}-selflink.patch"
	AT_M4DIR="m4 gl/m4 lgl/m4" eautoreconf
}

src_compile() {
	econf  \
		--without-included-opencdk \
		$(use_with zlib) \
		$(use_with lzo) \
		$(use_enable nls) \
		$(use_enable guile) \
		$(use_enable doc gtk-doc) \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog NEWS \
		README THANKS doc/TODO

	if use doc ; then
		dodoc doc/README.autoconf doc/tex/gnutls.ps
		docinto examples
		dodoc doc/examples/*.c
	fi
}
