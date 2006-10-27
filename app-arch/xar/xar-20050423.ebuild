# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/xar/xar-20050423.ebuild,v 1.4 2006/10/08 16:08:18 grobian Exp $

EAPI="prefix"

inherit eutils flag-o-matic autotools

DESCRIPTION="The XAR project aims to provide an easily extensible archive format."
HOMEPAGE="http://www.opendarwin.org/projects/xar/"
SRC_URI="http://www.opendarwin.org/projects/xar/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="debug"

RDEPEND="virtual/libc"
DEPEND="${RDEPEND}
	dev-libs/openssl
	dev-libs/libxml2
	sys-libs/zlib"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-amd64.patch
	epatch "${FILESDIR}/${P}-ldflags.patch"

	eautoreconf
}

src_compile() {
	use debug && myconf="${myconf} --enable-symbols"
	use ppc64 && myconf="${myconf} --enable-64bit"
	use sparc && myconf="${myconf} --enable-64bit-vis"

	# This is a var used by AMD64-multilib, unset this
	# or we'll have problems during econf/emake
	unset SYMLINK_LIB

	econf ${myconf} || die
	emake CFLAGS_OPTIMIZE="${CFLAGS}" LDFLAGS_OPTIMIZE="${LDFLAGS}" || die
}

src_install() {
	make DESTDIR="${D}" install || die
}
