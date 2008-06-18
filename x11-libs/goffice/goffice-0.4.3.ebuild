# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/goffice/goffice-0.4.3.ebuild,v 1.9 2008/01/10 19:41:36 welp Exp $

EAPI="prefix"

inherit eutils gnome2 flag-o-matic

DESCRIPTION="A library of document-centric objects and utilities"
HOMEPAGE="http://freshmeat.net/projects/goffice/"

LICENSE="GPL-2"
SLOT="0.4"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="doc gnome"
#cairo support broken and -gtk broken

RDEPEND=">=dev-libs/glib-2.8.0
	>=gnome-extra/libgsf-1.13.3
	>=dev-libs/libxml2-2.4.12
	>=x11-libs/pango-1.8.1
	>=x11-libs/gtk+-2.6
	>=gnome-base/libglade-2.3.6
	>=gnome-base/libgnomeprint-2.8.2
	>=media-libs/libart_lgpl-2.3.11
	>=x11-libs/cairo-1.2
	gnome? (
		>=gnome-base/gconf-2
		>=gnome-base/libgnomeui-2 )
	  dev-libs/libpcre"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.18
	>=dev-util/intltool-0.28
	doc? ( >=dev-util/gtk-doc-1.4 )"

DOCS="AUTHORS BUGS ChangeLog MAINTAINERS NEWS README"

pkg_setup() {
	G2CONF="${G2CONF} $(use_with gnome)"

	local diemessage=""

	if use gnome && ! built_with_use gnome-extra/libgsf gnome; then
		eerror "Please rebuild gnome-extra/libgsf with gnome support enabled"
		eerror "echo \"gnome-extra/libgsf gnome\" >> /etc/portage/package.use"
		eerror "or add  \"gnome\" to your USE string in /etc/make.conf"
		diemessage="No Gnome support found in libgsf."
	fi

	if ! built_with_use x11-libs/cairo svg; then
		eerror "Please rebuild x11-libs/cairo with svg support enabled"
		eerror "echo \"x11-libs/cairo svg\" >> /etc/portage/package.use"
		eerror "emerge -1 x11-libs/cairo"
		diemessage="${diemessage} No SVG support found in cairo."
	fi

	if ! built_with_use dev-libs/libpcre unicode; then
		eerror "Please rebuild dev-libs/libpcre with unicode support enabled"
		eerror "echo \"dev-libs/libpcre unicode\" >> /etc/portage/package.use"
		eerror "emerge -1 dev-libs/libpcre"
		diemessage="${diemessage} No unicode support found in libpcre."
	fi

	[ -n "${diemessage}" ] && die ${diemessage}
}

src_unpack() {
	gnome2_src_unpack

	# fix tests
	echo "goffice/component/go-component-factory.c" >> po/POTFILES.in
	echo "goffice/graph/gog-graph-prefs.glade" >> po/POTFILES.in
	echo "goffice/graph/gog-renderer-cairo.c" >> po/POTFILES.in
	echo "goffice/graph/gog-series-prefs.glade" >> po/POTFILES.in
	echo "goffice/graph/gog-smoothed-curve.c" >> po/POTFILES.in
	echo "goffice/graph/gog-trend-line.c" >> po/POTFILES.in
	echo "goffice/gtk/go-color-selector.c" >> po/POTFILES.in
	echo "goffice/gtk/go-image-save-dialog-extra.glade" >> po/POTFILES.in
	echo "goffice/gtk/go-palette.c" >> po/POTFILES.in
	echo "plugins/plot_boxes/gog-histogram.c" >> po/POTFILES.in
	echo "plugins/reg_linear/gog-power-reg.c" >> po/POTFILES.in
}

src_compile() {
	filter-flags -ffast-math
	gnome2_src_compile
}
