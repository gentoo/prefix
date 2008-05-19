# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-arch/xarchiver/xarchiver-0.4.6.ebuild,v 1.1 2008/05/11 14:07:16 drac Exp $

EAPI="prefix"

inherit fdo-mime gnome2-utils

DESCRIPTION="a GTK+ based and advanced archive manager that can be used with Thunar file manager."
HOMEPAGE="http://xarchiver.xfce.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="debug"

RDEPEND=">=x11-libs/gtk+-2.6
	>=dev-libs/glib-2.6"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/pkgconfig"

src_compile() {
	econf --disable-dependency-tracking $(use_enable debug)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
	elog "You need external programs for some formats, including"
	elog "arj - app-arch/unarj app-arch/arj"
	elog "zip - app-arch/unzip app-arch/zip"
	elog "rar - app-arch/unrar app-arch/rar"
	elog "7zip - app-arch/p7zip"
	elog "lha - app-arch/lha"
	elog "Make sure to install xfce-extra/thunar-archive plug-in."
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
	gnome2_icon_cache_update
}
