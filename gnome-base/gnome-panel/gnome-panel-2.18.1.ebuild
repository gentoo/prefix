# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-panel/gnome-panel-2.18.1.ebuild,v 1.1 2007/04/17 03:16:51 compnerd Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="The GNOME panel"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 FDL-1.1 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE="doc eds"

RDEPEND=">=gnome-base/gnome-desktop-2.12
	>=x11-libs/gtk+-2.10
	>=gnome-base/libglade-2.5
	>=gnome-base/libgnome-2.13
	>=gnome-base/libgnomeui-2.5.4
	>=gnome-base/libbonoboui-2.1.1
	>=gnome-base/orbit-2.4
	>=gnome-base/gnome-vfs-2.14.2
	>=x11-libs/libwnck-2.13.5
	>=gnome-base/gconf-2.6.1
	>=gnome-base/gnome-menus-2.11.1
	>=gnome-base/libbonobo-2
	||  (
			>=dev-libs/dbus-glib-0.71
			( <sys-apps/dbus-0.90 >=sys-apps/dbus-0.60 )
		)
	x11-libs/libXau
	media-libs/libpng
	>=x11-libs/cairo-1.0.0
	>=x11-libs/pango-1.15.4
	eds? ( >=gnome-extra/evolution-data-server-1.6 )"
DEPEND="${RDEPEND}
	app-text/scrollkeeper
	>=dev-util/pkgconfig-0.9
	>=dev-util/intltool-0.35
	>=app-text/gnome-doc-utils-0.3.2
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="--disable-scrollkeeper $(use_enable eds) \
			--with-in-process-applets=clock,notification-area,wncklet"
}

src_unpack() {
	gnome2_src_unpack

	# FIXME : uh yeah, this is nice
	# We should patch in a switch here and send it upstream
	sed -i 's:--load:-v:' ${S}/gnome-panel/Makefile.in || die "sed failed"
}

pkg_postinst() {
	local entries="${EPREFIX}/etc/gconf/schemas/panel-default-setup.entries"
	if [ -e "$entries" ]; then
		einfo "setting panel gconf defaults..."
		GCONF_CONFIG_SOURCE=`${EROOT}/usr/bin/gconftool-2 --get-default-source`
		${EROOT}/usr/bin/gconftool-2 --direct --config-source \
			${GCONF_CONFIG_SOURCE} --load=${entries}
	fi

	# Calling this late so it doesn't process the GConf schemas file we already
	# took care of.
	gnome2_pkg_postinst
}
