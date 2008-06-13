# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-xkb/xfce4-xkb-0.4.3-r1.ebuild,v 1.15 2008/04/25 16:10:13 drac Exp $

EAPI="prefix"

inherit autotools xfce44

xfce44

DESCRIPTION="XKB layout switching panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

DEPEND="dev-util/pkgconfig
	dev-util/intltool
	x11-proto/kbproto
	xfce-extra/xfce4-dev-tools"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "/^AC_INIT/s/xkb_version()/xkb_version/" configure.in
	intltoolize --force --copy --automake || die "intltoolize failed."
	AT_M4DIR=/usr/share/xfce4/dev-tools/m4macros eautoreconf
}

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
