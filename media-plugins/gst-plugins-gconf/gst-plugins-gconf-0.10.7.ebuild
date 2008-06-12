# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/gst-plugins-gconf/gst-plugins-gconf-0.10.7.ebuild,v 1.1 2008/02/21 12:14:40 zaheerm Exp $

EAPI="prefix"

inherit gnome2 gst-plugins-good gst-plugins10

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=gnome-base/gconf-2
	>=media-libs/gstreamer-0.10.17
	>=media-libs/gst-plugins-base-0.10.17"
DEPEND="${RDEPEND}"

GST_PLUGINS_BUILD="gconf gconftool"

# override eclass
src_unpack() {
	unpack ${A}
}

src_compile() {
	gst-plugins-good_src_configure ${@}

	gst-plugins10_find_plugin_dir
	emake || die "compile failure"

	cd ${S}/gconf
	emake || die "compile failure"
}

src_install() {
	gst-plugins10_find_plugin_dir
	einstall || die

	cd ${S}/gconf
	gnome2_src_install || die
}
