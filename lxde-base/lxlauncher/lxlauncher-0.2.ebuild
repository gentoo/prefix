# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/lxde-base/lxlauncher/lxlauncher-0.2.ebuild,v 1.1 2008/11/07 14:59:32 yngwin Exp $

EAPI=1

DESCRIPTION="An open source clone of the Asus launcher for EeePC"
HOMEPAGE="http://lxde.sf.net/"
SRC_URI="mirror://sourceforge/lxde/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="dev-libs/glib:2
	x11-libs/gtk+:2
	gnome-base/gnome-menus
	x11-libs/startup-notification"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/gettext
	!lxde-base/lxlauncher-gmenu"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog README
}
