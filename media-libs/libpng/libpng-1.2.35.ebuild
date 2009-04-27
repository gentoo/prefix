# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.35.ebuild,v 1.8 2009/03/19 14:31:50 armin76 Exp $

inherit autotools multilib eutils

MY_PV=${PV/_}
DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${PN}-${MY_PV}.tar.lzma"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

S=${WORKDIR}/${PN}-${MY_PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.24-pngconf-setjmp.patch
	epatch "${FILESDIR}"/${PN}-1.2.25-interix.patch

	# So we get sane .so versioning on FreeBSD
	eautoreconf # required for winnt, was elibtoolize originally.
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
