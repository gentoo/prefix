# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/hicolor-icon-theme/hicolor-icon-theme-0.11.ebuild,v 1.2 2009/12/13 17:22:33 ssuominen Exp $

inherit gnome2-utils

DESCRIPTION="Fallback theme for the freedesktop icon theme specification"
HOMEPAGE="http://icon-theme.freedesktop.org/wiki/HicolorTheme"
SRC_URI="http://icon-theme.freedesktop.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RESTRICT="binchecks strip"

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog README
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
