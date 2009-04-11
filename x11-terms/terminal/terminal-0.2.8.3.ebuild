# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/terminal/terminal-0.2.8.3.ebuild,v 1.8 2008/12/15 04:51:48 jer Exp $

inherit fdo-mime gnome2-utils flag-o-matic

MY_P=${P/t/T}

DESCRIPTION="Terminal for Xfce desktop environment, based on vte library."
HOMEPAGE="http://www.xfce.org/projects/terminal"
SRC_URI="mirror://xfce/xfce-4.4.3/src/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris"
IUSE="dbus debug doc nls startup-notification"

RDEPEND=">=dev-libs/glib-2.6:2
	media-libs/fontconfig
	media-libs/freetype
	>=x11-libs/gtk+-2.6:2
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXft
	x11-libs/libXrender
	x11-libs/vte
	>=xfce-extra/exo-0.3.4
	startup-notification? ( x11-libs/startup-notification )
	dbus? ( dev-libs/dbus-glib )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext
	doc? ( dev-libs/libxslt )"

S=${WORKDIR}/${MY_P}

pkg_preinst() {
	gnome2_icon_savelist
}

src_compile() {
	append-flags -Wno-error
	econf --disable-dependency-tracking \
		$(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable doc xsltproc) \
		$(use_enable nls) \
		$(use_enable startup-notification)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog HACKING NEWS README THANKS TODO
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/terminal/terminal-0.2.8.3.ebuild,v 1.2 2008/10/31 00:31:49 aballier Exp $

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
