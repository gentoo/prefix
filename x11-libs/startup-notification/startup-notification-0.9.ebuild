# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/startup-notification/startup-notification-0.9.ebuild,v 1.10 2007/09/22 05:00:32 tgall Exp $

inherit gnome.org autotools

DESCRIPTION="Application startup notification and feedback library"
HOMEPAGE="http://www.freedesktop.org/software/startup-notification"

LICENSE="LGPL-2 BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libSM
	x11-libs/libICE"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-libs/libXt"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README doc/startup-notification.txt
}
