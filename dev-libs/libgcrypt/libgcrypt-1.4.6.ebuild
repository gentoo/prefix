# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgcrypt/libgcrypt-1.4.6.ebuild,v 1.11 2011/01/21 02:12:03 robbat2 Exp $

EAPI="3"

inherit autotools eutils

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/libgcrypt/${P}.tar.bz2
	ftp://ftp.gnupg.org/gcrypt/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.5"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.4.0-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-1.4.0-interix3.patch

	# remove the included libtool.m4 to force a new libtool
	# to be used.
	rm -f m4/libtool.m4

	AT_M4DIR="m4" eautoreconf # need new libtool for interix
	# Fix build failure with non-bash /bin/sh.
	#eautoreconf

	epunt_cxx
}

src_configure() {
	# --disable-padlock-support for bug #201917
	# O-flag-mungling: https://bugs.g10code.com/gnupg/issue992
	econf \
		--disable-padlock-support \
		--disable-dependency-tracking \
		--with-pic \
		--enable-noexecstack \
		$(use_enable static-libs static) \
		$(use_enable !mips-irix O-flag-munging)
	
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README* THANKS TODO || die "dodoc failed"
}
