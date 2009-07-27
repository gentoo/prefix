# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/startup-notification/startup-notification-0.10.ebuild,v 1.2 2009/07/26 10:38:43 eva Exp $

EAPI="2"
WANT_AUTOMAKE="1.10"

inherit autotools

DESCRIPTION="Application startup notification and feedback library"
HOMEPAGE="http://www.freedesktop.org/software/startup-notification"
SRC_URI="http://freedesktop.org/software/${PN}/releases/${P}.tar.gz"

LICENSE="LGPL-2 BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libSM
	x11-libs/libICE
	x11-libs/libxcb
	>=x11-libs/xcb-util-0.3"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	x11-proto/xproto
	x11-libs/libXt"

src_prepare() {
	# Do not build tests unless required
	epatch "${FILESDIR}/${P}-tests.patch"

	eautomake
}

src_configure() {
	econf --disable-static
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README doc/startup-notification.txt || die "dodoc failed"
}
