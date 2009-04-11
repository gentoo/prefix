# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.24.1.ebuild,v 1.1 2009/03/17 08:42:54 nirbheek Exp $

inherit eutils gnome2 pam

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug doc hal pam test"

RDEPEND=">=dev-libs/glib-2.16
	 >=x11-libs/gtk+-2.6
	 gnome-base/gconf
	 >=sys-apps/dbus-1.0
	 hal? ( >=sys-apps/hal-0.5.7 )
	 pam? ( virtual/pam )
	 >=dev-libs/libgcrypt-1.2.2
	 >=dev-libs/libtasn1-0.3.4"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

# upstream bug: http://bugzilla.gnome.org/show_bug.cgi?id=553164
RESTRICT="test"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable hal)
		$(use_enable test tests)
		$(use_enable pam)
		$(use_with pam pam-dir $(getpam_mod_dir))
		--with-root-certs=${EPREFIX}/usr/share/ca-certificates/
		--enable-acl-prompts
		--enable-ssh-agent"
}

src_unpack() {
	gnome2_src_unpack

	epatch "${FILESDIR}"/${PN}-2.22.1-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.22.1-interix3.patch
}

