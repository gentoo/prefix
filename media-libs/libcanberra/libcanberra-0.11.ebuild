# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcanberra/libcanberra-0.11.ebuild,v 1.12 2010/07/20 03:01:15 jer Exp $

EAPI=1

inherit gnome2-utils

DESCRIPTION="Portable Sound Event Library"
HOMEPAGE="http://0pointer.de/lennart/projects/libcanberra/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="alsa doc gstreamer +gtk oss"

RDEPEND="media-libs/libvorbis
	sys-devel/libtool
	alsa? ( media-libs/alsa-lib )
	gstreamer? ( >=media-libs/gstreamer-0.10.15 )
	gtk? ( dev-libs/glib:2
		>=x11-libs/gtk+-2.13.4:2
		>=gnome-base/gconf-2 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.17
	doc? ( >=dev-util/gtk-doc-1.9 )"

src_compile() {
	econf --disable-static \
		$(use_enable alsa) \
		$(use_enable gstreamer) \
		$(use_enable gtk) \
		$(use_enable oss) \
		$(use_enable doc gtk-doc) \
		--disable-pulse \
		--disable-tdb \
		--disable-lynx
	# tdb support would need a split-out from samba before we can use it

	emake || die "emake failed."
}

src_install() {
	# we must delay gconf schema installation due to sandbox
	export GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL="1"

	emake DESTDIR="${D}" install || die "emake install failed."

	unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL

	rm "${ED}/usr/share/doc/${PN}/README"
	# If the rmdir errors, you probably need to add a file to dodoc
	# and remove the package installed above
	rmdir "${ED}/usr/share/doc/${PN}"
	dodoc README
}

pkg_preinst() {
	gnome2_gconf_savelist
}

pkg_postinst() {
	gnome2_gconf_install
}

#pkg_prerm() {
#	gnome2_gconf_uninstall
#}
