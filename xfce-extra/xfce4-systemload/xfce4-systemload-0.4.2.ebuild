# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-systemload/xfce4-systemload-0.4.2.ebuild,v 1.16 2008/04/25 15:52:56 drac Exp $

EAPI="prefix"

inherit autotools xfce44

xfce44

DESCRIPTION="System load monitor panel plugin"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"

DEPEND="xfce-extra/xfce4-dev-tools
	dev-util/intltool"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "/^AC_INIT/s/systemload_version()/systemload_version/" configure.in
	intltoolize --force --copy --automake || die "intltoolize failed."
	AT_M4DIR=/usr/share/xfce4/dev-tools/m4macros eautoreconf
}

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
