# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcanberra/libcanberra-0.22.ebuild,v 1.9 2010/07/20 03:01:15 jer Exp $

EAPI="1"

inherit eutils gnome2-utils autotools

DESCRIPTION="Portable Sound Event Library"
HOMEPAGE="http://0pointer.de/lennart/projects/libcanberra/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="alsa doc gstreamer +gtk oss pulseaudio"

RDEPEND="media-libs/libvorbis
	sys-devel/libtool
	alsa? ( media-libs/alsa-lib )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.11 )
	gstreamer? ( >=media-libs/gstreamer-0.10.15 )
	gtk? ( dev-libs/glib:2
		>=x11-libs/gtk+-2.13.4:2
		>=gnome-base/gconf-2 )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.17
	dev-util/gtk-doc-am
	doc? ( >=dev-util/gtk-doc-1.9 )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix bug 277739, replace LT_PREREQ and LT_INIT by AC_LIBTOOL*
	# macros (equivalent for earlier version), preserve backward
	# compatibility with libtool-1
	epatch "${FILESDIR}/${PN}-0.14-backward-compatibility-libtool.patch"

	# Fix bug 278354, Backport AM_GCONF_SOURCE_2 macro to m4/ dir
	# in case where gconf isn't installed on the system
	# (eautoconf could fail)
	epatch "${FILESDIR}/${PN}-0.14-am-gconf-source-2-m4.patch"

	rm lt*    || die "clean-up ltmain.sh failed"
	rm m4/lt* || die "clean-up lt scripts failed"
	rm m4/libtool* || die "clean-up libtool script failed"

	eautoreconf
}

src_compile() {
	econf --disable-static \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		$(use_enable alsa) \
		$(use_enable gstreamer) \
		$(use_enable gtk) \
		$(use_enable oss) \
		$(use_enable pulseaudio pulse) \
		$(use_enable doc gtk-doc) \
		--disable-tdb \
		--disable-lynx \
		--with-html-dir=/usr/share/doc/${PF}/html
	# tdb support would need a split-out from samba before we can use it

	emake || die "emake failed."
}

src_install() {
	# we must delay gconf schema installation due to sandbox
	#export GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL="1"

	emake DESTDIR="${D}" install || die "emake install failed."

	#unset GCONF_DISABLE_MAKEFILE_SCHEMA_INSTALL
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
