# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/recode/recode-3.6-r2.ebuild,v 1.20 2007/03/20 13:42:55 uberlord Exp $

EAPI="prefix"

inherit flag-o-matic eutils libtool toolchain-funcs

DEB_VER=11
DESCRIPTION="Convert files between various character sets"
HOMEPAGE="http://recode.progiciels-bpi.ca/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-debian-${DEB_VER}.patch

	# Needed under FreeBSD, too
	epatch "${FILESDIR}"/${P}-ppc-macos.diff
	cp lib/error.c lib/xstrdup.c src/ || die "file copy failed"

	use ppc-macos && append-ldflags -lgettextlib
	elibtoolize
}

src_compile() {
	tc-export CC LD
	# --without-included-gettext means we always use system headers
	# and library
	econf --without-included-gettext $(use_enable nls) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS BACKLOG ChangeLog NEWS README THANKS TODO
	rm -f "${ED}"/usr/lib/charset.alias
}
