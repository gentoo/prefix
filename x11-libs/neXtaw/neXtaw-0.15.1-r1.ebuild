# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/neXtaw/neXtaw-0.15.1-r1.ebuild,v 1.16 2007/07/22 02:59:44 dberkholz Exp $

EAPI="prefix"

DESCRIPTION="Athena Widgets with N*XTSTEP appearance"
HOMEPAGE="http://siag.nu/neXtaw/"
SRC_URI="http://siag.nu/pub/neXtaw/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

DEPEND="x11-libs/libICE
	x11-libs/libXext
	x11-libs/libXt
	x11-libs/libX11
	x11-libs/libSM
	x11-libs/libXmu
	x11-libs/libxkbfile
	x11-libs/libXpm
	x11-proto/xextproto
	x11-proto/xproto
	!<x11-libs/neXtaw-0.15.1-r1"

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog INSTALL NEWS README TODO
}
