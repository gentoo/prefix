# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gvfs/gvfs-0.2.5-r3.ebuild,v 1.12 2009/01/20 11:13:56 armin76 Exp $

inherit bash-completion gnome2 eutils autotools

DESCRIPTION="GNOME Virtual Filesystem Layer"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="avahi cdda doc fuse gnome gphoto2 hal gnome-keyring samba"

RDEPEND=">=dev-libs/glib-2.16
		 >=sys-apps/dbus-1.0
		 >=net-libs/libsoup-2.4
		 dev-libs/libxml2
		 net-misc/openssh
		 avahi? ( >=net-dns/avahi-0.6 )
		 cdda?  (
					>=sys-apps/hal-0.5.10
					>=dev-libs/libcdio-0.78.2
				)
		 fuse? ( sys-fs/fuse )
		 gnome? ( >=gnome-base/gconf-2.0 )
		 hal? ( >=sys-apps/hal-0.5.10 )
		 gphoto2? ( >=media-libs/libgphoto2-2.4 )
		 gnome-keyring? ( >=gnome-base/gnome-keyring-1.0 )
		 samba? ( >=net-fs/samba-3 )"
DEPEND="${RDEPEND}
		>=dev-util/intltool-0.35
		>=dev-util/pkgconfig-0.19
		doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
			--enable-http
			--disable-bash-completion
			--disable-archive
			$(use_enable avahi)
			--disable-obexftp
			$(use_enable cdda)
			$(use_enable fuse)
			$(use_enable gnome gconf)
			$(use_enable gphoto2)
			$(use_enable hal)
			$(use_enable gnome-keyring KEYRING)
			$(use_enable samba)"

	if use cdda && built_with_use dev-libs/libcdio minimal; then
		ewarn
		ewarn "CDDA support in gvfs requires dev-libs/libcdio to be built"
		ewarn "without the minimal USE flag."
		die "Please re-emerge dev-libs/libcdio without the minimal USE flag"
	fi
}

src_unpack() {
	gnome2_src_unpack
	epatch "${FILESDIR}"/${PN}-0.2.3-interix.patch
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_header_stropts_h=no

	gnome2_src_compile
}

src_unpack() {
	gnome2_src_unpack

	# fixes bug #236862 (backport from 0.99*)
	epatch "${FILESDIR}/${PN}-0.2.5-dbus-crash.patch"

	epatch "${FILESDIR}/${PN}-0.2.5-bash-completion.patch"
	eautoreconf
}

src_install() {
	gnome2_src_install
	use bash-completion && \
		dobashcompletion programs/gvfs-bash-completion.sh ${PN}
}

pkg_postinst() {
	gnome2_pkg_postinst
	use bash-completion && bash-completion_pkg_postinst
}
