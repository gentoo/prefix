# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/rzip/rzip-2.1.ebuild,v 1.6 2007/06/09 17:14:22 welp Exp $

EAPI="prefix"

inherit autotools

DESCRIPTION="compression program for large files"
HOMEPAGE="http://rzip.samba.org/"
SRC_URI="http://rzip.samba.org/ftp/rzip/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="app-arch/bzip2
	>=sys-devel/autoconf-2.59"
RDEPEND="app-arch/bzip2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.0-darwin.patch
	WANT_AUTOCONF="2.5" eautoreconf
}

src_install() {
	make DESTDIR="${D}" install || die "failed installing"
}
