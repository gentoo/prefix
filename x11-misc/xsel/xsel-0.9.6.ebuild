# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xsel/xsel-0.9.6.ebuild,v 1.8 2007/02/04 18:46:17 beandog Exp $

EAPI="prefix"

DESCRIPTION="XSel is a command-line program for getting and setting the contents of the X selection."
HOMEPAGE="http://www.vergenet.net/~conrad/software/xsel"
SRC_URI="http://www.vergenet.net/~conrad/software/xsel/download/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_compile() {
	econf || die "econf failed"
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
