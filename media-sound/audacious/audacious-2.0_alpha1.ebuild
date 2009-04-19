# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/audacious/audacious-2.0_alpha1.ebuild,v 1.2 2009/04/18 06:21:40 mr_bones_ Exp $

inherit eutils

MY_P="${P/_/-}"
S="${WORKDIR}/${MY_P}"
DESCRIPTION="Audacious Player - Your music, your way, no exceptions"
HOMEPAGE="http://audacious-media-player.org/"
SRC_URI="http://distfiles.atheme.org/${MY_P}.tgz
	 mirror://gentoo/gentoo_ice-xmms-0.2.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="altivec chardet nls libsamplerate session sse2"

RDEPEND=">=dev-libs/dbus-glib-0.60
	>=dev-libs/glib-2.14
	>=dev-libs/libmcs-0.7.1-r2
	>=dev-libs/libmowgli-0.7.0
	dev-libs/libxml2
	>=x11-libs/cairo-1.2.6
	>=x11-libs/gtk+-2.10
	>=x11-libs/pango-1.8.0
	libsamplerate? ( media-libs/libsamplerate )
	session? ( x11-libs/libSM )"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9.0
	nls? ( dev-util/intltool )"

PDEPEND=">=media-plugins/audacious-plugins-2.0_alpha1"

src_compile() {
	# D-Bus is a mandatory dependency, remote control,
	# session management and some plugins depend on this.
	# Building without D-Bus is *unsupported* and a USE-flag
	# will not be added due to the bug reports that will result.
	# Bugs #197894, #199069, #207330, #208606
	# Disabling XSPF playlists would make startup *very* slow as
	# all plugins will then have to re-probed each time.
	econf \
		--enable-dbus \
		--enable-xspf \
		$(use_enable altivec) \
		$(use_enable chardet) \
		$(use_enable nls) \
		$(use_enable session sm) \
		$(use_enable sse2) \
		$(use_enable libsamplerate samplerate) \
		|| die

	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS NEWS README

	# Gentoo_ice skin installation; bug #109772
	insinto /usr/share/audacious/Skins/gentoo_ice
	doins "${WORKDIR}"/gentoo_ice/*
	docinto gentoo_ice
	dodoc "${WORKDIR}"/README
}

pkg_postinst() {
	elog "Note that you need to recompile *all* third-party plugins for Audacious 2.0"
	elog "Plugins compiled against 1.X will not be loaded."
}
