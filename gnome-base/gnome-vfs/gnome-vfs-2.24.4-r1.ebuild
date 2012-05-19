# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-vfs/gnome-vfs-2.24.4-r1.ebuild,v 1.6 2012/05/15 23:41:59 aballier Exp $

EAPI="3"
GCONF_DEBUG="no"

inherit autotools eutils gnome2 virtualx

DESCRIPTION="Gnome Virtual Filesystem"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="acl avahi doc fam gnutls ipv6 kerberos samba ssl"

RDEPEND=">=gnome-base/gconf-2
	>=dev-libs/glib-2.9.3
	>=dev-libs/libxml2-2.6
	app-arch/bzip2
	gnome-base/gnome-mime-data
	>=x11-misc/shared-mime-info-0.14
	>=dev-libs/dbus-glib-0.71
	acl? (
		sys-apps/acl
		sys-apps/attr )
	avahi? ( >=net-dns/avahi-0.6 )
	kerberos? ( virtual/krb5 )
	fam? ( virtual/fam )
	samba? ( >=net-fs/samba-3 )
	ssl? (
		gnutls?	(
			net-libs/gnutls
			!gnome-extra/gnome-vfs-sftp )
		!gnutls? (
			>=dev-libs/openssl-0.9.5
			!gnome-extra/gnome-vfs-sftp ) )
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	gnome-base/gnome-common
	>=dev-util/intltool-0.40
	virtual/pkgconfig
	>=dev-util/gtk-doc-am-1.13
	doc? ( >=dev-util/gtk-doc-1 )"

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
		--disable-hal
		$(use_enable ipv6)
		$(use_enable kerberos krb5)
		$(use_enable samba)
		$(use_enable ssl openssl)"
		# Useless ? --enable-http-neon

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
	#still necessary on 2.24.4?
	#[[ ${CHOST} == *-darwin* ]] && export LIBS="${LIBS} -lresolv"
}

src_prepare() {
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
	epatch "${FILESDIR}"/${PN}-2.24.4-home_dir_fakeroot.patch

	# Configure with gnutls-2.7, bug #253729
	# Fix building with gnutls-2.12, bug #388895
	epatch "${FILESDIR}"/${PN}-2.24.4-gnutls27.patch

	# Prevent duplicated volumes, bug #193083
	epatch "${FILESDIR}"/${PN}-2.24.0-uuid-mount.patch

	# Do not build tests with FEATURES="-test", bug #226221
	epatch "${FILESDIR}"/${PN}-2.24.4-build-tests-asneeded.patch

	# Disable broken test, bug #285706
	epatch "${FILESDIR}"/${PN}-2.24.4-disable-test-async-cancel.patch

	# Fix deprecated API disabling in used libraries - this is not future-proof, bug 212163
	# upstream bug #519632
	sed -i -e '/DISABLE_DEPRECATED/d' \
		daemon/Makefile.am daemon/Makefile.in \
		libgnomevfs/Makefile.am libgnomevfs/Makefile.in \
		modules/Makefile.am modules/Makefile.in \
		test/Makefile.am test/Makefile.in || die
	sed -i -e 's:-DG_DISABLE_DEPRECATED:$(NULL):g' \
		programs/Makefile.am programs/Makefile.in || die

	epatch "${FILESDIR}"/${PN}-2.22.0-interix.patch
	epatch "${FILESDIR}"/${PN}-2.22.0-interix6.patch
	# this patch would break other interix versions where this is fixed.
	# sadly enough there is no define which let's me check which version
	# of interix i'm compiling on, so the patch needs to be applied
	# conditionally.
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-2.22.0-interix3.patch

	intltoolize --force --copy --automake || die "intltoolize failed"
	eautoreconf

	gnome2_src_prepare
}

src_test() {
	unset DISPLAY
	# Fix bug #285706
	unset XAUTHORITY
	Xemake check || die "tests failed"
}

src_install() {
	gnome2_src_install
	find "${ED}/usr/$(get_libdir)/gnome-vfs-2.0/modules/" -name "*.la" -delete || die
}
