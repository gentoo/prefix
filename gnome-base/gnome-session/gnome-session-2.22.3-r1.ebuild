# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-session/gnome-session-2.22.3-r1.ebuild,v 1.10 2009/04/27 14:35:32 jer Exp $

inherit eutils gnome2 autotools

DESCRIPTION="Gnome session manager"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${SRC_URI}
		 branding? ( mirror://gentoo/gentoo-splash.png )"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="branding ipv6 tcpd"

RDEPEND=">=dev-libs/glib-2.13
		 >=gnome-base/libgnomeui-2.2
		 >=x11-libs/gtk+-2.11.1
		 >=dev-libs/dbus-glib-0.71
		 >=gnome-base/gnome-keyring-2.21.92
		 gnome-base/gnome-settings-daemon
		 >=x11-libs/libnotify-0.2.1
		 x11-libs/libXau
		 x11-apps/xdpyinfo
		 >=gnome-base/gconf-2
		 tcpd? ( >=sys-apps/tcp-wrappers-7.6 )"
DEPEND="${RDEPEND}
		  x11-apps/xrdb
		>=sys-devel/gettext-0.10.40
		>=dev-util/pkgconfig-0.17
		>=dev-util/intltool-0.35
		!gnome-base/gnome-core
		!<gnome-base/gdm-2.20.4"

# gnome-base/gnome-core overwrite /usr/bin/gnome-session
# gnome-base/gdm does not provide gnome.desktop anymore

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	# TODO: convert libnotify to a configure option
	G2CONF="${G2CONF} $(use_enable ipv6) $(use_enable tcpd tcp-wrappers) --with-settings-daemon=/usr/libexec/gnome-settings-daemon"
}

src_unpack() {
	gnome2_src_unpack

	# Patch for Gentoo Branding (bug #42687)
	use branding && epatch "${FILESDIR}/${PN}-2.17.90.1-gentoo-branding.patch"

	# Get rid of random asserts in tons of programs due to development versions
	epatch "${FILESDIR}/${PN}-2.19.2-no-asserts.patch"

	# Spawn GSD instead of relying on D-Bus, as this falls down quite
	# spectacularly on SMP systems (bug #239293)
	epatch "${FILESDIR}/${P}-gsd-spawn.patch"
	eautoreconf
}

src_install() {
	gnome2_src_install

	dodir /etc/X11/Sessions
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}/Gnome"

	# Our own splash for world domination
	if use branding ; then
		insinto /usr/share/pixmaps/splash/
		doins "${DISTDIR}/gentoo-splash.png"
	fi
}
