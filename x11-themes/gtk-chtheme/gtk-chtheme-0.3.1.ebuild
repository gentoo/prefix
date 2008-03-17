# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-chtheme/gtk-chtheme-0.3.1.ebuild,v 1.10 2007/11/28 09:34:08 corsair Exp $

EAPI="prefix"

DESCRIPTION="GTK-2.0 Theme Switcher"
HOMEPAGE="http://plasmasturm.org/programs/gtk-chtheme/"
SRC_URI="http://plasmasturm.org/programs/gtk-chtheme/${P}.tar.bz2"

IUSE=""
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
LICENSE="GPL-2"

RDEPEND=">=x11-libs/gtk+-2"
DEPEND="${RDEPEND}
		dev-util/pkgconfig"

src_compile() {
		emake || die
}

src_install() {
		einstall DESTDIR=${ED} || die
}
