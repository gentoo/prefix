# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/terminal/terminal-0.2.12.ebuild,v 1.11 2009/07/27 17:39:39 nixnut Exp $

EAPI="1"

MY_P="${P/t/T}"
inherit autotools xfce4

XFCE_VERSION=4.6.1

xfce4_core

DESCRIPTION="Terminal for Xfce desktop environment, based on vte library."
HOMEPAGE="http://www.xfce.org/projects/terminal"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
IUSE="dbus debug startup-notification doc"

RDEPEND=">=dev-libs/glib-2.6:2
	media-libs/fontconfig
	media-libs/freetype
	>=x11-libs/gtk+-2.10:2
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXft
	x11-libs/libXrender
	>=x11-libs/vte-0.11.11
	>=xfce-extra/exo-0.3.4
	startup-notification? ( x11-libs/startup-notification )
	dbus? ( dev-libs/dbus-glib )"
DEPEND="${RDEPEND}
	dev-util/intltool
	dev-util/xfce4-dev-tools
	doc? ( dev-libs/libxslt )"

XFCE4_PATCHES="${FILESDIR}/${PN}-configure.in.patch"
DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable dbus) $(use_enable doc xsltproc)"
}

src_unpack() {
	xfce4_src_unpack
	AT_M4DIR="${EPREFIX}"/usr/share/xfce4/dev-tools/m4macros eautoreconf
}
