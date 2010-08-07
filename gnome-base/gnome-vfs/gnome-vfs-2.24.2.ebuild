# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-vfs/gnome-vfs-2.24.2.ebuild,v 1.7 2010/07/20 01:52:41 jer Exp $

inherit autotools eutils gnome2

DESCRIPTION="Gnome Virtual Filesystem"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="acl avahi doc fam gnutls hal ipv6 kerberos samba ssl"

RDEPEND=">=gnome-base/gconf-2
	>=dev-libs/glib-2.9.3
	>=dev-libs/libxml2-2.6
	app-arch/bzip2
	fam? ( virtual/fam )
	gnome-base/gnome-mime-data
	>=x11-misc/shared-mime-info-0.14
	>=dev-libs/dbus-glib-0.71
	samba? ( >=net-fs/samba-3 )
	gnutls?	(
		net-libs/gnutls
		!gnome-extra/gnome-vfs-sftp )
	ssl? (
		!gnutls? (
			>=dev-libs/openssl-0.9.5
			!gnome-extra/gnome-vfs-sftp ) )
	hal? ( >=sys-apps/hal-0.5.7 )
	avahi? ( >=net-dns/avahi-0.6 )
	kerberos? ( virtual/krb5 )
	acl? (
		sys-apps/acl
		sys-apps/attr )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	gnome-base/gnome-common
	>=dev-util/intltool-0.40
	>=dev-util/pkgconfig-0.9
	>=dev-util/gtk-doc-am-1.10-r1
	doc? ( >=dev-util/gtk-doc-1 )"
PDEPEND="hal? ( >=gnome-base/gnome-mount-0.6 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-schemas-install
		--disable-static
		--disable-cdda
		--disable-howl
		$(use_enable acl)
		$(use_enable avahi)
		$(use_enable fam)
		$(use_enable gnutls)
		$(use_enable hal)
		$(use_enable ipv6)
		$(use_enable kerberos krb5)
		$(use_enable samba)
		$(use_enable ssl openssl)"
		# Useless ? --enable-http-neon

	if use hal ; then
		G2CONF="${G2CONF}
			--with-hal-mount=${EPREFIX}/usr/bin/gnome-mount \
			--with-hal-umount=${EPREFIX}/usr/bin/gnome-umount \
			--with-hal-eject=${EPREFIX}/usr/bin/gnome-eject"
	fi

	# this works because of the order of configure parsing
	# so should always be behind the use_enable options
	# foser <foser@gentoo.org 19 Apr 2004
	use gnutls && use ssl && G2CONF="${G2CONF} --disable-openssl"

	if [[ ${CHOST} == *-interix* ]]; then
		export ac_cv_func_poll=no
		export ac_cv_header_poll_h=no
		export ac_cv_header_stropts_h=no
	fi

	# this is a crude hack, but the configure script is so messed up on
	# res_init, that this is the easiest way out
	[[ ${CHOST} == *-darwin* ]] && export LIBS="${LIBS} -lresolv"
}

src_unpack() {
	gnome2_src_unpack

	# Allow the Trash on afs filesystems (#106118)
	epatch "${FILESDIR}"/${PN}-2.12.0-afs.patch

	# Fix compiling with headers missing
	epatch "${FILESDIR}"/${PN}-2.15.2-headers-define.patch

	# Fix for crashes running programs via sudo
	epatch "${FILESDIR}"/${PN}-2.16.0-no-dbus-crash.patch

	# Fix automagic dependencies, upstream bug #493475
	epatch "${FILESDIR}"/${PN}-2.20.0-automagic-deps.patch
	epatch "${FILESDIR}"/${PN}-2.20.1-automagic-deps.patch

	# Fix to identify ${HOME} (#200897)
	# thanks to debian folks
	epatch "${FILESDIR}"/${PN}-2.20.0-home_dir_fakeroot.patch

	# Configure with gnutls-2.7, bug #253729
	epatch "${FILESDIR}"/${PN}-2.24.0-gnutls27.patch

	# Prevent duplicated volumes, bug #193083
	epatch "${FILESDIR}"/${PN}-2.24.0-uuid-mount.patch

	# Fix deprecated API disabling in used libraries - this is not future-proof, bug 212163
	# upstream bug #519632
	sed -i -e '/DISABLE_DEPRECATED/d' \
		daemon/Makefile.am daemon/Makefile.in \
		libgnomevfs/Makefile.am libgnomevfs/Makefile.in \
		modules/Makefile.am modules/Makefile.in \
		test/Makefile.am test/Makefile.in
	sed -i -e 's:-DG_DISABLE_DEPRECATED:$(NULL):g' \
		programs/Makefile.am programs/Makefile.in

	epatch "${FILESDIR}"/${PN}-2.22.0-interix.patch
	epatch "${FILESDIR}"/${PN}-2.22.0-interix6.patch
	# this patch would break other interix versions where this is fixed.
	# sadly enough there is no define which let's me check which version
	# of interix i'm compiling on, so the patch needs to be applied
	# conditionally.
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.22.0-interix3.patch

	# Fix use of broken gtk-doc.make
	if use doc; then
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=/usr/bin/gtkdoc-rebase" -i gtk-doc.make
	else
		sed "/^TARGET_DIR/i \GTKDOC_REBASE=true" -i gtk-doc.make
	fi

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf
}

src_test() {
	unset DISPLAY
	#unset DBUS_SESSION_BUS_ADDRESS
	emake check || die "tests failed"
}
