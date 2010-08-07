# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-keyring/gnome-keyring-2.22.3-r1.ebuild,v 1.14 2010/07/20 01:50:46 jer Exp $

inherit gnome2 eutils pam autotools

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug doc hal pam test"

RDEPEND=">=dev-libs/glib-2.8
	 >=x11-libs/gtk+-2.6
	 gnome-base/gconf
	 >=sys-apps/dbus-1.0
	 hal? ( >=sys-apps/hal-0.5.7 )
	 pam? ( virtual/pam )
	 >=dev-libs/libgcrypt-1.2.2
	 >=dev-libs/libtasn1-1"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	dev-util/gtk-doc-am
	doc? ( dev-util/gtk-doc )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable debug)
		$(use_enable hal)
		$(use_enable test tests)
		$(use_enable pam)
		$(use_with pam pam-dir $(getpam_mod_dir))
		--with-root-certs=${EPREFIX}/usr/share/ca-certificates/"
}

src_unpack() {
	gnome2_src_unpack

	# Backport from trunk for fixing upstream bug #511285, bug #238098
	epatch "${FILESDIR}/${P}-warnings.patch"

	# Fix configure with recent libtasn1, bug #266554
	epatch "${FILESDIR}/${P}-pkg-libtasn1.patch"

	epatch "${FILESDIR}"/${PN}-2.22.1-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.22.1-interix3.patch

	intltoolize --force --copy --automake || die "inltoolize failed"
	eautoreconf
}

