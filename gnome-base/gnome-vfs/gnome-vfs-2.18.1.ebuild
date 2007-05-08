# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-vfs/gnome-vfs-2.18.1.ebuild,v 1.1 2007/04/17 03:32:28 compnerd Exp $

EAPI="prefix"

WANT_AUTOMAKE=1.8
inherit eutils gnome2 autotools

DESCRIPTION="Gnome Virtual Filesystem"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="avahi doc gnutls hal ipv6 samba ssl"

RDEPEND=">=gnome-base/gconf-2
	>=dev-libs/glib-2.9.3
	>=gnome-base/orbit-2.12.4
	>=dev-libs/libxml2-2.6
	>=net-misc/neon-0.25.3
	app-arch/bzip2
	virtual/fam
	gnome-base/gnome-mime-data
	>=x11-misc/shared-mime-info-0.14
	|| ( >=dev-libs/dbus-glib-0.71 <sys-apps/dbus-0.90 )
	samba? ( >=net-fs/samba-3 )
	gnutls?	(
				net-libs/gnutls
				!gnome-extra/gnome-vfs-sftp
			)
	ssl?	(
		!gnutls?	(
				>=dev-libs/openssl-0.9.5
				!gnome-extra/gnome-vfs-sftp
				)
		)
	hal?	(
				>=sys-apps/hal-0.5.7
			)
	avahi? ( >=net-dns/avahi-0.6 )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/gtk-doc-1
	gnome-base/gnome-common
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9"
PDEPEND="hal? ( >=gnome-base/gnome-mount-0.4 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"

pkg_setup() {
	if use hal ; then
		G2CONF="--with-hal-mount=${EPREFIX}/usr/bin/gnome-mount \
				--with-hal-umount=${EPREFIX}/usr/bin/gnome-umount \
				--with-hal-eject=${EPREFIX}/usr/bin/gnome-eject"
	fi

	G2CONF="${G2CONF}                 \
		--disable-schemas-install     \
		--disable-cdda                \
		--disable-howl                \
		--enable-http-neon            \
		$(use_enable ssl openssl)     \
		$(use_enable gnutls)          \
		$(use_enable samba)           \
		$(use_enable ipv6)            \
		$(use_enable hal)             \
		$(use_enable avahi)"

	# this works because of the order of conifgure parsing
	# so should always be behind the use_enable options
	# foser <foser@gentoo.org 19 Apr 2004
	use gnutls && use ssl && G2CONF="${G2CONF} --disable-openssl"
}

src_unpack() {
	gnome2_src_unpack

	# Allow the Trash on afs filesystems (#106118)
	epatch "${FILESDIR}"/${PN}-2.12.0-afs.patch

	# Fix compiling with headers missing
	epatch "${FILESDIR}"/${PN}-2.15.2-headers-define.patch

	# Fix for crashes running programs via sudo
	epatch "${FILESDIR}"/${PN}-2.16.0-no-dbus-crash.patch

	eautoreconf
	intltoolize --force
}
