# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/terminal/terminal-0.2.10.ebuild,v 1.2 2009/03/10 17:38:48 angelos Exp $

MY_P="${P/t/T}"
inherit xfce4

XFCE_VERSION=4.6.0

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
	doc? ( dev-libs/libxslt )"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable dbus) $(use_enable doc xsltproc)"
}

DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/terminal/terminal-0.2.10.ebuild,v 1.2 2009/03/10 17:38:48 angelos Exp $

inherit xfce44

XFCE_VERSION=4.4.2
xfce44

MY_P=${P/t/T}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Terminal for Xfce desktop environment, based on vte library."
HOMEPAGE="http://www.xfce.org/projects/terminal"

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
IUSE="dbus debug startup-notification doc"

RDEPEND=">=dev-libs/glib-2.6
	>=x11-libs/gtk+-2.6
	media-libs/fontconfig
	media-libs/freetype
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXft
	x11-libs/libXrender
	startup-notification? ( x11-libs/startup-notification )
	dbus? ( dev-libs/dbus-glib )
	>=x11-libs/vte-0.11.11
	>=xfce-extra/exo-0.3.4"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	doc? ( dev-libs/libxslt )"

XFCE_CONFIG="${XFCE_CONFIG} $(use_enable dbus) $(use_enable doc xsltproc)"
DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"

xfce44_extra_package
