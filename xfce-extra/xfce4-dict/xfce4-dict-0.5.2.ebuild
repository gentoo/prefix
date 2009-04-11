# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-dict/xfce4-dict-0.5.2.ebuild,v 1.8 2009/02/04 21:17:43 armin76 Exp $

EAPI=1

inherit fdo-mime gnome2-utils

DESCRIPTION="plugin and stand-alone application to query dict.org"
HOMEPAGE="http://goodies.xfce.org/projects/applications/xfce4-dict"
SRC_URI="http://goodies.xfce.org/releases/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6:2
	>=x11-libs/gtk+-2.6:2
	>=xfce-base/libxfcegui4-4.4
	>=xfce-base/libxfce4util-4.4
	>=xfce-base/xfce4-panel-4.4"
DEPEND="${RDEPEND}
	dev-util/intltool"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update

	if ! has_version app-text/aspell && ! has_version app-text/ispell \
	&& ! has_version app-text/enchant; then
		echo
		elog "You need a spell check program for spell checking."
		elog "xfce4-dict works with enchant, aspell, ispell or any other spell"
		elog "check program which is compatible with the ispell command"
		elog "The dictionary function will still work without those"
	fi
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
