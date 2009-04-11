# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/gnutls-2.6.0-r2.ebuild,v 1.3 2009/01/10 01:33:11 dragonheart Exp $

inherit eutils libtool autotools

DESCRIPTION="A TLS 1.0 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"

MINOR_VERSION="${PV#*.}"
MINOR_VERSION="${MINOR_VERSION%.*}"
if [[ $((MINOR_VERSION % 2)) == 0 ]] ; then
	#SRC_URI="ftp://ftp.gnu.org/pub/gnu/${PN}/${P}.tar.bz2"
	SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2"
else
	SRC_URI="ftp://alpha.gnu.org/gnu/${PN}/${P}.tar.bz2"
fi
unset MINOR_VERSION

# GPL-3 for the gnutls-extras library and LGPL for the gnutls library.
LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
EAPI=1
IUSE="bindist +cxx doc guile lzo nls zlib"

RDEPEND="dev-libs/libgpg-error
	>=dev-libs/libgcrypt-1.4.0
	>=dev-libs/libtasn1-0.3.4
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
	for dir in gl/m4 m4 lib/gl/m4 lib/m4 libextra/gl/m4 libextra/m4 ; do
		rm -f ${dir}/lt* ${dir}/libtool.m4
	done
	find . -name ltmain.sh -exec rm {} \;

	epatch "${FILESDIR}"/${P}-cxx-configure.in.patch
	epatch "${FILESDIR}"/${P}-openpgp-selftest.patch
	eautoreconf
	epatch "${FILESDIR}"/gnutls-2.2.5-CVE-2008-4989-V2.patch

	epatch "${FILESDIR}"/${PN}-2.5.3-interix.patch

	elibtoolize # for sane .so versioning on FreeBSD
}

src_compile() {
	local myconf
	use bindist && myconf="--without-lzo" || myconf="$(use_with lzo)"
	econf  \
		$(use_with zlib) \
		$(use_enable nls) \
		$(use_enable guile) \
		$(use_enable cxx) \
		$(use_enable doc gtk-doc) \
		${myconf}
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README THANKS doc/TODO

	if use doc ; then
		dodoc doc/README.autoconf doc/tex/gnutls.ps
		docinto examples
		dodoc doc/examples/*.c
	fi
}
