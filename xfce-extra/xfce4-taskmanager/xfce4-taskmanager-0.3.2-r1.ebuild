# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/xfce-extra/xfce4-taskmanager/xfce4-taskmanager-0.3.2-r1.ebuild,v 1.11 2008/05/04 11:07:15 drac Exp $

EAPI="prefix"

inherit autotools eutils xfce44

xfce44

DESCRIPTION="Task Manager"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
HOMEPAGE="http://goodies.xfce.org/projects/applications/xfce4-taskmanager"
SRC_URI="http://goodies.xfce.org/releases/${PN}/${P}${COMPRESS}"

RDEPEND=">=xfce-base/libxfcegui4-${XFCE_MASTER_VERSION}
	>=xfce-base/libxfce4util-${XFCE_MASTER_VERSION}"
DEPEND="${RDEPEND}
	xfce-extra/xfce4-dev-tools"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "/^AC_INIT/s/taskmanager_version()/taskmanager_version/" configure.in
	intltoolize --force --copy --automake || die "intltoolize failed."
	AT_M4DIR="${EPREFIX}/usr/share/xfce4/dev-tools/m4macros" eautoreconf
}

src_install() {
	xfce44_src_install
	make_desktop_entry ${PN} "Task Manager" xfce-system-settings "System;Utility;Core;GTK"
}
