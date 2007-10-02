# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.20.0.ebuild,v 1.1 2007/10/01 09:13:05 leio Exp $

EAPI="prefix"

inherit gnome2 eutils

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="hal pam test"

RDEPEND=">=dev-libs/glib-2.6
		>=x11-libs/gtk+-2.6
		>=sys-apps/dbus-1.0
		hal? ( >=sys-apps/hal-0.5.7 )
		pam? ( sys-libs/pam )
		>=dev-libs/libgcrypt-1.2.2"
DEPEND="${RDEPEND}
		sys-devel/gettext
		>=dev-util/intltool-0.35
		>=dev-util/pkgconfig-0.9"

DOCS="AUTHORS ChangeLog NEWS README TODO"

src_unpack() {
	gnome2_src_unpack

	# Fix tests
	echo "gkr-ask-tool.c" >> ${S}/po/POTFILES.in
}

pkg_setup() {
	G2CONF="$(use_enable hal) $(use_enable pam) $(use_enable test tests)"
}
