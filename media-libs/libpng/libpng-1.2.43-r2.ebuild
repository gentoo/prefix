# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.43-r2.ebuild,v 1.9 2010/05/12 18:28:17 armin76 Exp $

EAPI=3
inherit libtool autotools

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="sys-libs/zlib
	!<media-libs/libpng-1.2.43-r2"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

src_prepare() {
	# required to get new/patched libtool, which knows better about eprefix!
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die
}
