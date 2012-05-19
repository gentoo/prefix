# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcanberra/libcanberra-0.28-r5.ebuild,v 1.9 2012/05/15 23:37:01 aballier Exp $

EAPI="4"

inherit gnome2-utils libtool systemd autotools eutils

DESCRIPTION="Portable Sound Event Library"
HOMEPAGE="http://0pointer.de/lennart/projects/libcanberra/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="alsa gnome gstreamer +gtk +gtk3 oss pulseaudio +sound tdb udev"

COMMON_DEPEND="media-libs/libvorbis
	>=sys-devel/libtool-2.2.6b
	alsa? (
		media-libs/alsa-lib
		udev? ( >=sys-fs/udev-160 ) )
	gstreamer? ( >=media-libs/gstreamer-0.10.15 )
	gtk? ( >=x11-libs/gtk+-2.20.0:2
		gnome-base/gconf:2 )
	gtk3? ( x11-libs/gtk+:3
		gnome-base/gconf:2 )
	pulseaudio? ( >=media-sound/pulseaudio-0.9.11 )
	tdb? ( sys-libs/tdb )
"
RDEPEND="${COMMON_DEPEND}
	gnome? ( gnome-base/gsettings-desktop-schemas )
	sound? ( x11-themes/sound-theme-freedesktop )" # Required for index.theme wrt #323379
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig"

REQUIRED_USE="udev? ( alsa )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-underlinking.patch

	# https://bugs.freedesktop.org/show_bug.cgi?id=35024
	epatch "${FILESDIR}/${PN}-0.28-workaround-hang.patch"

	# gconf-2.m4 is needed for autoconf, bug #374561
	if ! use gtk && ! use gtk3 ; then
		cp "${FILESDIR}/gconf-2.m4" m4/ || die "Copying gconf-2.m4 failed!"
	fi

	eautoreconf
	elibtoolize
}

src_configure() {
	econf \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--disable-dependency-tracking \
		$(use_enable alsa) \
		$(use_enable oss) \
		$(use_enable pulseaudio pulse) \
		$(use_enable gstreamer) \
		$(use_enable gtk) \
		$(use_enable gtk3) \
		$(use_enable tdb) \
		$(use_enable udev) \
		$(systemd_with_unitdir) \
		--disable-lynx \
		--disable-gtk-doc \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html
}

src_install() {
	# Disable parallel installation until bug #253862 is solved
	emake -j1 DESTDIR="${D}" install

	# Remove useless .la files:
	# libcanberra uses lt_dlopenext instead of ld_dlopen to load the modules,
	# which means that it will first try appending ".la" to the given filename
	# prefix; if that fails, it will append the module extension for the
	# current system and try that (".so" on Linux, ".bundle" on Darwin, ".dll"
	# on Windows, etc.).  Only if both fail will it return an error.
	find "${ED}" -name '*.la' -exec rm -f {} + || die "la file removal failed"
}

pkg_preinst() { gnome2_gconf_savelist; }
pkg_postinst() { gnome2_gconf_install; }
