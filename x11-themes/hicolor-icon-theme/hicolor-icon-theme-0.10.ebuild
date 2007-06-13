# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/hicolor-icon-theme/hicolor-icon-theme-0.10.ebuild,v 1.10 2007/06/06 16:39:04 drac Exp $

EAPI="prefix"

inherit eutils gnome2-utils

DESCRIPTION="Fallback theme for the freedesktop icon theme specification"
HOMEPAGE="http://icon-theme.freedesktop.org/wiki/HicolorTheme"
SRC_URI="http://icon-theme.freedesktop.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""
RESTRICT="binchecks strip"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog README
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
