# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xclip/xclip-0.11.ebuild,v 1.1 2009/01/18 23:09:50 nelchael Exp $

DESCRIPTION="Command-line utility to read data from standard in and place it in an X selection"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://sourceforge.net/projects/xclip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXt
	x11-libs/libXext"
DEPEND="${RDEPEND}"

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog README
}
