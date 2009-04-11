# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-eyes/xfce4-eyes-4.4.0.ebuild,v 1.23 2008/09/21 19:04:04 angelos Exp $

inherit autotools eutils xfce44

xfce44

DESCRIPTION="panel plugin that adds eyes which watch your every step"

KEYWORDS="~amd64-linux ~x86-linux"
IUSE="debug"

DEPEND="dev-util/pkgconfig
	dev-util/intltool
	dev-util/xfce4-dev-tools"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-libtool.patch
	sed -i -e "/^AC_INIT/s/eyes_version()/eyes_version/" configure.in
	intltoolize --force --copy --automake || die "intltoolize failed."
	AT_M4DIR="${EPREFIX}/usr/share/xfce4/dev-tools/m4macros" eautoreconf
}

DOCS="AUTHORS ChangeLog NEWS README"

xfce44_goodies_panel_plugin
