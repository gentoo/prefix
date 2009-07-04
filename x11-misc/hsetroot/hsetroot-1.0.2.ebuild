# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/hsetroot/hsetroot-1.0.2.ebuild,v 1.12 2009/07/02 20:49:32 idl0r Exp $

EAPI="2"

inherit autotools

DESCRIPTION="Tool which allows you to compose wallpapers ('root pixmaps') for X"
HOMEPAGE="http://thegraveyard.org/hsetroot.php"
SRC_URI="http://thegraveyard.org/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11
	>=media-libs/imlib2-1.0.6.2003[X]"
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_prepare() {
	# The pre-generated configure script contains unneeded deps
	eautoreconf
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README || die
}
