# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/gnome-terminal/gnome-terminal-2.24.2-r1.ebuild,v 1.10 2009/04/27 14:27:34 jer Exp $

inherit eutils gnome2

DESCRIPTION="The Gnome Terminal"
HOMEPAGE="http://www.gnome.org/"

SRC_URI="${SRC_URI}
	mirror://gentoo/gnome-terminal-2.24.2-restore-switch-to-tab-i18n.patch.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="x11-libs/libXft
	>=dev-libs/glib-2.16.0
	>=x11-libs/gtk+-2.13.6
	>=gnome-base/gconf-2.14
	>=x11-libs/startup-notification-0.8
	>=x11-libs/vte-0.17.0
	>=gnome-base/libgnome-2.14
	>=gnome-base/libgnomeui-2"
DEPEND="${RDEPEND}
	  sys-devel/gettext
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	  gnome-base/gnome-common
	>=app-text/gnome-doc-utils-0.3.2
	>=app-text/scrollkeeper-0.3.11"

DOCS="AUTHORS ChangeLog HACKING NEWS README"

src_unpack() {
	gnome2_src_unpack

	# Use login shell by default (#12900)
	epatch "${FILESDIR}"/${PN}-2.22.0-default_shell.patch

	# Restore switch to tab <n> keybinding preferences ...
	epatch "${FILESDIR}/${P}-restore-switch-to-tab.patch"
	# ... and the translations for it
	epatch "${DISTDIR}/${P}-restore-switch-to-tab-i18n.patch.bz2"

	# patch gnome terminal to report as GNOME rather than xterm
	# This needs to resolve a few bugs (#120294,)
	# Leave out for now; causing too many problems
	#epatch ${FILESDIR}/${PN}-2.13.90-TERM-gnome.patch
}
