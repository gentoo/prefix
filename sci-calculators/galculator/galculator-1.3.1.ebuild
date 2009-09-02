# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-calculators/galculator/galculator-1.3.1.ebuild,v 1.5 2007/11/17 13:22:46 nixnut Exp $

DESCRIPTION="GTK+ based algebraic and RPN calculator."
HOMEPAGE="http://galculator.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="gnome"

RDEPEND=">=x11-libs/gtk+-2.6
	>=gnome-base/libglade-2
	gnome? ( gnome-base/gnome-desktop )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	use gnome || sed -i -e 's:gnome-calc2.png:calc:' "${S}"/galculator.desktop.in
	# Fix tests
	echo "about.glade" >> "${S}/po/POTFILES.skip"
	echo "basic_buttons.glade" >> "${S}/po/POTFILES.skip"
	echo "classic_view.glade" >> "${S}/po/POTFILES.skip"
	echo "dispctrl_bottom.glade" >> "${S}/po/POTFILES.skip"
	echo "dispctrl_right.glade" >> "${S}/po/POTFILES.skip"
	echo "dispctrl_right_vertical.glade" >> "${S}/po/POTFILES.skip"
	echo "main_frame.glade" >> "${S}/po/POTFILES.skip"
	echo "paper_view.glade" >> "${S}/po/POTFILES.skip"
	echo "prefs.glade" >> "${S}/po/POTFILES.skip"
	echo "scientific_buttons.glade" >> "${S}/po/POTFILES.skip"
	echo "ui/dispctrl_right_vertical.glade" >> "${S}/po/POTFILES.skip"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
