# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/gnutls-2.2.1.ebuild,v 1.2 2008/01/18 23:08:15 alonbl Exp $

EAPI="prefix"

inherit libtool autotools

DESCRIPTION="A TLS 1.0 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"
SRC_URI="http://josefsson.org/gnutls/releases/${P}.tar.bz2"

# GPL-3 for the gnutls-extras library and LGPL for the gnutls library.
LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="zlib lzo doc nls guile bindist"

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

pkg_setup() {
	if use guile && ! built_with_use dev-scheme/guile networking; then
		eerror "You are trying to compile ${PN} package with USE=\"guile\""
		eerror "while dev-scheme/guile does not have USE=\"networking\""
		die
	fi
	if use lzo && use bindist; then
		eerror "lzo is not allowed in binary distribution of gnutls"
		die
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize # for sane .so versioning on FreeBSD
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
