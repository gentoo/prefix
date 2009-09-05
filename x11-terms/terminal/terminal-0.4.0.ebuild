# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/terminal/terminal-0.4.0.ebuild,v 1.10 2009/09/04 21:13:44 billie Exp $

EAPI=2
MY_P=${P/t/T}
inherit xfconf

DESCRIPTION="Terminal for Xfce desktop environment, based on vte library."
HOMEPAGE="http://www.xfce.org/projects/terminal"
SRC_URI="mirror://xfce/src/apps/${PN}/0.4/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
IUSE="dbus debug doc"

RDEPEND=">=dev-libs/glib-2.6:2
	media-libs/fontconfig
	media-libs/freetype:2
	>=x11-libs/gtk+-2.6:2
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXft
	x11-libs/libXrender
	x11-libs/vte
	>=xfce-base/exo-0.3.4
	x11-libs/startup-notification
	dbus? ( dev-libs/dbus-glib )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext
	doc? ( dev-libs/libxslt )
	dev-util/xfce4-dev-tools"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	intltoolize --force --copy --automake || die "intltoolize failed"
	AT_M4DIR="${EPREFIX}/usr/share/xfce4/dev-tools/m4macros" eautoreconf
}

pkg_setup() {
	XFCONF="--disable-dependency-tracking
		$(use_enable dbus)
		$(use_enable debug)
		$(use_enable doc xsltproc)"
	DOCS="AUTHORS ChangeLog HACKING NEWS README THANKS TODO"
}
