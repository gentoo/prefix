# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.40.ebuild,v 1.10 2010/01/31 16:11:01 armin76 Exp $

inherit autotools multilib eutils

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/libpng/${P}.tar.bz2"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="sys-libs/zlib"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.25-interix.patch

	# required for interix, winnt
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES KNOWNBUG README TODO Y2KINFO
}
