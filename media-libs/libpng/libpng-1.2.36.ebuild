# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.36.ebuild,v 1.1 2009/05/07 17:49:45 vapier Exp $

inherit autotools multilib eutils

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.lzma"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.25-interix.patch

#	eautoreconf # required for winnt
	# So we get sane .so versioning on FreeBSD
	elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO
}
