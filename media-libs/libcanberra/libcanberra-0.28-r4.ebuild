# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libcanberra/libcanberra-0.28-r4.ebuild,v 1.1 2011/07/21 17:26:29 pacho Exp $

EAPI="4"

inherit gnome2-utils libtool systemd autotools eutils

DESCRIPTION="Portable Sound Event Library"
HOMEPAGE="http://0pointer.de/lennart/projects/libcanberra/"
SRC_URI="http://0pointer.de/lennart/projects/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="alsa gstreamer +gtk +gtk3 oss pulseaudio +sound tdb udev"

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
	sound? ( x11-themes/sound-theme-freedesktop )" # Required for index.theme wrt #323379
DEPEND="${COMMON_DEPEND}
	>=dev-util/pkgconfig-0.17"

REQUIRED_USE="udev? ( alsa )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-underlinking.patch

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
	emake -j1 DESTDIR="${D}" install || die

	# Remove useless .la files
	# la files in /usr/lib*/${P}/ are needed
	if use gtk || use gtk3; then
		rm -v "${ED}"/usr/$(get_libdir)/gtk-*/modules/*.la || die
	fi
	rm -v "${ED}"/usr/$(get_libdir)/*.la || die
}

pkg_preinst() { gnome2_gconf_savelist; }
pkg_postinst() { gnome2_gconf_install; }
