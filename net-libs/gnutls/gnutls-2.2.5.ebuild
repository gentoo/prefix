# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/gnutls-2.2.5.ebuild,v 1.9 2008/11/04 03:40:02 vapier Exp $

inherit libtool eutils

DESCRIPTION="A TLS 1.0 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"
#SRC_URI="http://josefsson.org/gnutls/releases/${P}.tar.bz2"
SRC_URI="mirror://gnu/gnutls/${P}.tar.bz2"

# GPL-3 for the gnutls-extras library and LGPL for the gnutls library.
LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="zlib lzo doc nls guile bindist"

RDEPEND="dev-libs/libgpg-error
	>=dev-libs/libgcrypt-1.2.4
	>=dev-libs/libtasn1-0.3.4
	>=app-crypt/opencdk-0.6.4
	nls? ( virtual/libintl )
	guile? ( dev-scheme/guile )
	zlib? ( >=sys-libs/zlib-1.1 )
	!bindist? ( lzo? ( >=dev-libs/lzo-2 ) )"
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
		ewarn "lzo support was disabled for binary distribution of gnutls"
		ewarn "due to licensing issues. See Bug 202381 for details."
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-2.2.2-interix.patch

	elibtoolize # for sane .so versioning on FreeBSD
}

src_compile() {
	local myconf
	use bindist && myconf="--without-lzo" || myconf="$(use_with lzo)"
	econf  \
		--without-included-opencdk \
		$(use_with zlib) \
		$(use_enable nls) \
		$(use_enable guile) \
		$(use_enable doc gtk-doc) \
		${myconf}
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
