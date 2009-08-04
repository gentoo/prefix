# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/lxde-base/lxterminal/lxterminal-0.1.6.ebuild,v 1.1 2009/08/03 19:24:57 vostorga Exp $

EAPI=1

DESCRIPTION="Lightweight vte-based tabbed terminal emulator for LXDE"
HOMEPAGE="http://lxde.sf.net/"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
SLOT="0"
IUSE=""

RDEPEND="x11-libs/gtk+:2
	dev-libs/glib:2
	x11-libs/vte"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext
	>=dev-util/intltool-0.40.0"

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS README || die "dodoc failed"
}
