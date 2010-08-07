# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/glib-2.24.1-r1.ebuild,v 1.5 2010/08/01 11:04:08 fauli Exp $

EAPI="2"

inherit autotools gnome.org libtool eutils flag-o-matic

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc fam hardened selinux xattr"

RDEPEND="virtual/libiconv
	>=sys-devel/gettext-0.11
	xattr? ( sys-apps/attr )
	fam? ( virtual/fam )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16
	>=sys-devel/gettext-0.11
	>=dev-util/gtk-doc-am-1.11
	x86-interix? ( sys-libs/itx-bind )
	doc? (
		>=dev-libs/libxslt-1.0
		>=dev-util/gtk-doc-1.11
		~app-text/docbook-xml-dtd-4.1.2 )"
# eautoreconf needs gtk-doc-am
# XXX: Consider adding test? ( sys-devel/gdb ); assert-msg-test tries to use it

src_prepare() {
	if use ppc64 && use hardened ; then
		replace-flags -O[2-3] -O1
		epatch "${FILESDIR}/glib-2.6.3-testglib-ssp.patch"
	fi

	if use ia64 ; then
		# Only apply for < 4.1
		local major=$(gcc-major-version)
		local minor=$(gcc-minor-version)
		if (( major < 4 || ( major == 4 && minor == 0 ) )); then
			epatch "${FILESDIR}/glib-2.10.3-ia64-atomic-ops.patch"
		fi
	fi

	# patch avoids autoreconf necessity
	epatch "${FILESDIR}"/${PN}-2.12.11-solaris-thread.patch

	# Don't fail gio tests when ran without userpriv, upstream bug 552912
	# This is only a temporary workaround, remove as soon as possible
	epatch "${FILESDIR}/${PN}-2.18.1-workaround-gio-test-failure-without-userpriv.patch"

	# Fix gmodule issues on fbsd; bug #184301
	epatch "${FILESDIR}"/${PN}-2.12.12-fbsd.patch

	# Don't check for python, hence removing the build-time python dep.
	# We remove the gdb python scripts in src_install due to bug 291328
	epatch "${FILESDIR}/${PN}-2.24-punt-python-check.patch"

	# Fix test failure when upgrading from 2.22 to 2.24, upstream bug 621368
	epatch "${FILESDIR}/${PN}-2.24-assert-test-failure.patch"

	# Do not try to remove files on live filesystem, bug #XXX ?
	sed 's:^\(.*"/desktop-app-info/delete".*\):/*\1*/:' \
		-i "${S}"/gio/tests/desktop-app-info.c || die "sed failed"

	epatch "${FILESDIR}"/${PN}-2.16.3-macos-inline.patch
	epatch "${FILESDIR}"/${PN}-2.18.4-compile-warning-sol64.patch
	epatch "${FILESDIR}"/${PN}-2.20.3-mint.patch
	# configure script lets itself being fooled by bind 8 stuff
	[[ ${CHOST} == *-darwin[678] ]] && append-libs -lresolv

	# make default sane for us
	if use prefix ; then
		sed -i -e "s:/usr/local:${EPREFIX}:" gio/xdgmime/xdgmime.c || die
		# bug #308609, without path, bug #314057
		export PERL=perl
	fi

	# build glib with parity for native win32
	if [[ ${CHOST} == *-winnt* ]] ; then
		epatch "${FILESDIR}"/${PN}-2.18.3-winnt-lt2.patch
		# makes the iconv check more general, needed for winnt, but could
		# be useful for others too, requires eautoreconf
		epatch "${FILESDIR}"/${PN}-2.18.3-iconv.patch
		epatch "${FILESDIR}"/${PN}-2.20.5-winnt-exeext.patch
#		AT_M4DIR="m4macros" eautoreconf
	fi

	if [[ ${CHOST} == *-interix* ]]; then
		# conditional only to avoid auto-reconfing on other platforms.
		# there are hunks disabling some GTK_DOC macros - i guess that
		# the gtk-doc-am package in the tree is too old to bootstrap
		# glib correctly ... :/
		epatch "${FILESDIR}"/${PN}-2.22.3-interix.patch

		# interix 3 and 5 have no ipv6 support, so take it out (phew...)
		if [[ ${CHOST} == *-interix[35]* ]]; then
			epatch "${FILESDIR}"/${P}-interix-network.patch
		fi

		# activate the itx-bind package...
		append-flags "-I${EPREFIX}/usr/include/bind"
		append-ldflags "-L${EPREFIX}/usr/lib/bind"

#		AT_M4DIR="m4macros" eautoreconf
	fi

	# Needed for the punt-python-check patch.
	# Also needed to prevent croscompile failures, see bug #267603
	eautoreconf

	[[ ${CHOST} == *-freebsd* ]] && elibtoolize
}

src_configure() {
	local myconf

	epunt_cxx

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	# -- compnerd (3/27/06)
	use debug && myconf="--enable-debug"

	# non-glibc platforms use GNU libiconv, but configure needs to know about
	# that not to get confused when it finds something outside the prefix too
	if use !elibc_glibc ; then
		myconf="${myconf} --with-libiconv=gnu"
		# add the libdir for libtool, otherwise it'll make love with system
		# installed libiconv
		append-ldflags "-L${EPREFIX}/usr/$(get_libdir)"
	fi

	[[ ${CHOST} == *-interix* ]] && {
		export ac_cv_func_mmap_fixed_mapped=yes
		export ac_cv_func_poll=no
	}

	local mythreads=posix

	[[ ${CHOST} == *-mint* ]] && append-libs -lpthread
	[[ ${CHOST} == *-winnt* ]] && mythreads=win32
	# without this, AIX defines EEXIST and ENOTEMPTY to the same value
	[[ ${CHOST} == *-aix* ]] && append-cppflags -D_LINUX_SOURCE_COMPAT

	# Always build static libs, see #153807
	# Always use internal libpcre, bug #254659
	econf ${myconf}                 \
		  $(use_enable xattr)       \
		  $(use_enable doc man)     \
		  $(use_enable doc gtk-doc) \
		  $(use_enable fam)         \
		  $(use_enable selinux)     \
		  --enable-static           \
		  --enable-regex            \
		  --with-pcre=internal      \
		  --with-threads=${mythreads} \
		  --with-xml-catalog="${EPREFIX}"/etc/xml/catalog
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	# Don't install gdb python macros, bug 291328
	rm -rf "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"

	dodoc AUTHORS ChangeLog* NEWS* README || die "dodoc failed"
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	export XDG_CONFIG_DIRS="${EPREFIX}"/etc/xdg
	export XDG_DATA_DIRS="${EPREFIX}"/usr/local/share:"${EPREFIX}"/usr/share
	export XDG_DATA_HOME="${T}"
	emake check || die "tests failed"
}
