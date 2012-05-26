# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.5.0-r2.ebuild,v 1.3 2012/05/21 18:52:09 xarthisius Exp $

EAPI="4"

inherit autotools eutils

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
	ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}-idea.patch.bz2"

LICENSE="LGPL-2.1 MIT"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.8"
DEPEND="${RDEPEND}"

DOCS=( AUTHORS ChangeLog NEWS README THANKS TODO )

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.4.0-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-1.4.0-interix3.patch

	# remove the included libtool.m4 to force a new libtool
	# to be used.
	rm -f m4/libtool.m4

	AT_M4DIR="m4" eautoreconf # need new libtool for interix
	# Fix build failure with non-bash /bin/sh.
	epatch "${FILESDIR}"/${P}-uscore.patch
	epatch "${FILESDIR}"/${PN}-multilib-syspath.patch
	epatch "${WORKDIR}"/${P}-idea.patch
	#eautoreconf
}

src_configure() {
	# --disable-padlock-support for bug #201917
	# O-flag-mungling: https://bugs.g10code.com/gnupg/issue992
	econf \
		--disable-padlock-support \
		--disable-dependency-tracking \
		--enable-noexecstack \
		--disable-O-flag-munging \
		$(use_enable static-libs static) \
		$(use_enable !mips-irix O-flag-munging)
	
}

src_install() {
	default

	use static-libs || find "${ED}" -name '*.la' -delete
}
