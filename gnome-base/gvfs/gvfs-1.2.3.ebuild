# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gvfs/gvfs-1.2.3.ebuild,v 1.13 2010/07/19 22:09:04 jer Exp $

EAPI="2"

inherit autotools bash-completion gnome2 eutils flag-o-matic

DESCRIPTION="GNOME Virtual Filesystem Layer"
HOMEPAGE="http://www.gnome.org"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="archive avahi bluetooth cdda doc fuse gnome gnome-keyring gphoto2 hal samba"

RDEPEND=">=dev-libs/glib-2.19
	>=sys-apps/dbus-1.0
	>=net-libs/libsoup-2.25.1[gnome]
	dev-libs/libxml2
	net-misc/openssh
	archive? ( app-arch/libarchive )
	avahi? ( >=net-dns/avahi-0.6 )
	bluetooth? (
		dev-libs/dbus-glib
		net-wireless/bluez
		dev-libs/expat )
	cdda?  (
		>=sys-apps/hal-0.5.10
		>=dev-libs/libcdio-0.78.2[-minimal] )
	fuse? ( sys-fs/fuse )
	gnome? ( >=gnome-base/gconf-2.0 )
	gnome-keyring? ( >=gnome-base/gnome-keyring-1.0 )
	gphoto2? ( >=media-libs/libgphoto2-2.4 )
	hal? ( >=sys-apps/hal-0.5.10 )
	samba? ( >=net-fs/samba-3 )"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.19
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README TODO"

pkg_setup() {
	# CFLAGS needed for Solaris. Took it from here:
	# https://svn.sourceforge.net/svnroot/pkgbuild/spec-files-extra/trunk/SFEgnome-gvfs.spec
	[[ ${CHOST} == *-solaris* ]] && append-flags "-D_XPG4_2 -D__EXTENSIONS__"
	G2CONF="${G2CONF}
		--enable-http
		--disable-bash-completion
		$(use_enable archive)
		$(use_enable avahi)
		$(use_enable bluetooth obexftp)
		$(use_enable cdda)
		$(use_enable fuse)
		$(use_enable gnome gconf)
		$(use_enable gphoto2)
		$(use_enable hal)
		$(use_enable gnome-keyring keyring)
		$(use_enable samba)"
}

src_prepare() {
	gnome2_src_prepare

	# Conditional patching purely to avoid eautoreconf
	use gphoto2 && epatch "${FILESDIR}/${PN}-1.2.2-gphoto2-stricter-checks.patch"

	if use archive; then
		epatch "${FILESDIR}/${PN}-1.2.2-expose-archive-backend.patch"
		echo "mount-archive.desktop.in" >> po/POTFILES.in
		echo "mount-archive.desktop.in.in" >> po/POTFILES.in
	fi

	use gphoto2 || use archive && eautoreconf

	#epatch "${FILESDIR}"/${PN}-0.2.3-interix.patch
	# There is no mkdtemp on Solaris libc. Using the same code as on Interix	
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i -e 's:mkdtemp:mktemp:g' daemon/gvfsbackendburn.c
	fi
	[[ ${CHOST} == *-interix* ]] && export ac_cv_header_stropts_h=no
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
