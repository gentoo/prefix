# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/gnome-terminal/gnome-terminal-2.26.3.1-r2.ebuild,v 1.1 2009/09/11 15:52:36 nirbheek Exp $

inherit eutils gnome2

DESCRIPTION="The Gnome Terminal"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

# libgnome needed for some schema, bug #274638
RDEPEND=">=dev-libs/glib-2.16.0
	>=x11-libs/gtk+-2.14.0
	>=gnome-base/gconf-2.14
	>=x11-libs/startup-notification-0.8
	>=x11-libs/vte-0.20.0
	>=dev-libs/dbus-glib-0.6
	x11-libs/libSM
	gnome-base/libgnome"
DEPEND="${RDEPEND}
	  sys-devel/gettext
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	>=app-text/gnome-doc-utils-0.3.2
	>=app-text/scrollkeeper-0.3.11"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		--with-smclient-backend"
}

src_unpack() {
	gnome2_src_unpack

	# Use login shell by default (#12900)
	epatch "${FILESDIR}"/${PN}-2.22.0-default_shell.patch

	# If we're logged in root on the first tab, don't open a new tab
	# in user on /, fix bug #269318, import from upstream bug #565328.
	epatch "${FILESDIR}"/${P}-cwd-on-new-tab.patch

	# Fix bug 268846 -- gnome-terminal errors out if it can't find the gconf
	# daemon. Patch is from upstream git repository, included in 2.28
	epatch "${FILESDIR}"/${P}-partial-fix-dbus-error.patch

	# patch gnome terminal to report as GNOME rather than xterm
	# This needs to resolve a few bugs (#120294,)
	# Leave out for now; causing too many problems
	#epatch ${FILESDIR}/${PN}-2.13.90-TERM-gnome.patch
}
