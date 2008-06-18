# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.25.ebuild,v 1.9 2008/04/10 04:44:53 vapier Exp $

EAPI="prefix"

inherit autotools multilib eutils

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.bz2"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="sys-libs/zlib"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.24-pngconf-setjmp.patch
	epatch "${FILESDIR}"/${P}-interix.patch
	# So we get sane .so versioning on FreeBSD
	eautoreconf # need new libtool for interix
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO
}

pkg_postinst() {
	# the libpng authors really screwed around between 1.2.1 and 1.2.3
	if [[ -f ${EROOT}/usr/$(get_libdir)/libpng$(get_libname 3.1.2.1) ]] ; then
		rm -f "${EROOT}"/usr/$(get_libdir)/libpng$(get_libname 3.1.2.1)
	fi
}
