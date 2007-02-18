# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xbindkeys/xbindkeys-1.8.0.ebuild,v 1.1 2007/02/09 16:31:59 nelchael Exp $

EAPI="prefix"

DESCRIPTION="Tool for launching commands on keystrokes"
SRC_URI="http://hocwp.free.fr/xbindkeys/${P}.tar.gz"
HOMEPAGE="http://hocwp.free.fr/xbindkeys/"
LICENSE="GPL-2"

KEYWORDS="~amd64 ~ppc-macos ~x86"
SLOT="0"

IUSE="guile tk"

RDEPEND="|| ( x11-libs/libX11 virtual/x11 )
	guile? ( dev-scheme/guile )
	tk? ( dev-lang/tk )"

DEPEND="${RDEPEND}
	|| ( x11-proto/xproto virtual/x11 )"

src_compile() {

	local myconf
	use tk || myconf="${myconf} --disable-tk"
	use guile || myconf="${myconf} --disable-guile"

	econf ${myconf} || die
	emake DESTDIR=${D} || die

}

src_install() {

	emake DESTDIR=${D} \
		BINDIR=/usr/bin install || die "Installation failed"

}
