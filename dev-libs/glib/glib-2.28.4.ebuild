# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/glib-2.28.4.ebuild,v 1.2 2011/03/26 18:34:04 eva Exp $

EAPI="3"
PYTHON_DEPEND="2"

inherit autotools gnome.org libtool eutils flag-o-matic pax-utils python virtualx

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="debug doc fam +introspection selinux +static-libs test xattr"

RDEPEND="virtual/libiconv
	sys-libs/zlib
	xattr? ( sys-apps/attr )
	fam? ( virtual/fam )"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16
	>=sys-devel/gettext-0.11
	>=dev-util/gtk-doc-am-1.13
	x86-interix? ( sys-libs/itx-bind )
	doc? (
		>=dev-libs/libxslt-1.0
		>=dev-util/gtk-doc-1.13
		~app-text/docbook-xml-dtd-4.1.2 )
	test? ( >=sys-apps/dbus-1.2.14 )"
PDEPEND="introspection? ( dev-libs/gobject-introspection )
	!<gnome-base/gvfs-1.6.4-r990" # Earlier versions do not work with glib

# XXX: Consider adding test? ( sys-devel/gdb ); assert-msg-test tries to use it

pkg_setup() {
	python_set_active_version 2
}

src_prepare() {
	if use ia64 ; then
		# Only apply for < 4.1
		local major=$(gcc-major-version)
		local minor=$(gcc-minor-version)
		if (( major < 4 || ( major == 4 && minor == 0 ) )); then
			epatch "${FILESDIR}/glib-2.10.3-ia64-atomic-ops.patch"
		fi
	fi

	# patch avoids autoreconf necessity
	epatch "${FILESDIR}"/${PN}-2.26.1-solaris-thread.patch

	# Don't fail gio tests when ran without userpriv, upstream bug 552912
	# This is only a temporary workaround, remove as soon as possible
	epatch "${FILESDIR}/${PN}-2.18.1-workaround-gio-test-failure-without-userpriv.patch"

	# Fix gmodule issues on fbsd; bug #184301
	epatch "${FILESDIR}"/${PN}-2.12.12-fbsd.patch

	# For MiNT, bug #324233
	epatch "${FILESDIR}"/${PN}-2.22.5-nothreads.patch

	# Don't check for python, hence removing the build-time python dep.
	# We remove the gdb python scripts in src_install due to bug 291328
	epatch "${FILESDIR}/${PN}-2.25-punt-python-check.patch"

	# Fix test failure when upgrading from 2.22 to 2.24, upstream bug 621368
	epatch "${FILESDIR}/${PN}-2.24-assert-test-failure.patch"

	# Do not try to remove files on live filesystem, upstream bug #619274
	sed 's:^\(.*"/desktop-app-info/delete".*\):/*\1*/:' \
		-i "${S}"/gio/tests/desktop-app-info.c || die "sed failed"

	# Disable failing tests, upstream bug #???
	epatch "${FILESDIR}/${PN}-2.26.0-disable-locale-sensitive-test.patch"
	epatch "${FILESDIR}/${PN}-2.26.0-disable-volumemonitor-broken-test.patch"

	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' -i Makefile.am Makefile.in \
			|| die "sed failed"
	fi

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

	# Needed for the punt-python-check patch, disabling timeout test
	# Also needed to prevent croscompile failures, see bug #267603
	eautoreconf

	[[ ${CHOST} == *-freebsd* ]] && elibtoolize

	epunt_cxx
}

src_configure() {
	local myconf

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	# -- compnerd (3/27/06)
	# disable-visibility needed for reference debug, bug #274647
	use debug && myconf="--enable-debug --disable-visibility"

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
	[[ ${CHOST} == *-winnt* ]] && mythreads=win32

	# without this, AIX defines EEXIST and ENOTEMPTY to the same value
	[[ ${CHOST} == *-aix* ]] && append-cppflags -D_LINUX_SOURCE_COMPAT

	# Always use internal libpcre, bug #254659
	econf ${myconf} \
		$(use_enable xattr) \
		$(use_enable doc man) \
		$(use_enable doc gtk-doc) \
		$(use_enable fam) \
		$(use_enable selinux) \
		$(use_enable static-libs static) \
		--enable-regex \
		--with-pcre=internal \
		--with-threads=${mythreads} \
		--with-xml-catalog="${EPREFIX}"/etc/xml/catalog \
		--disable-dtrace \
		--disable-systemtap
}

src_install() {
	local f
	emake DESTDIR="${D}" install || die "Installation failed"

	# Don't install gdb python macros, bug 291328
	rm -rf "${ED}/usr/share/gdb/" "${ED}/usr/share/glib-2.0/gdb/"

	dodoc AUTHORS ChangeLog* NEWS* README || die "dodoc failed"

	insinto /usr/share/bash-completion
	for f in gdbus gsettings; do
		newins "${ED}/etc/bash_completion.d/${f}-bash-completion.sh" ${f} || die
	done
	rm -rf "${ED}/etc"
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	export XDG_CONFIG_DIRS="${EPREFIX}"/etc/xdg
	export XDG_DATA_DIRS="${EPREFIX}"/usr/local/share:"${EPREFIX}"/usr/share
	export G_DBUS_COOKIE_SHA1_KEYRING_DIR="${T}/temp"
	export XDG_DATA_HOME="${T}"
	unset GSETTINGS_BACKEND # bug 352451

	# Related test is a bit nitpicking
	mkdir "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"
	chmod 0700 "$G_DBUS_COOKIE_SHA1_KEYRING_DIR"

	# Hardened: gdb needs this, bug #338891
	if host-is-pax ; then
		pax-mark -mr "${S}"/tests/.libs/assert-msg-test \
			|| die "Hardened adjustment failed"
	fi

	# Need X for dbus-launch session X11 initialization
	Xemake check || die "tests failed"
}

pkg_preinst() {
	# Only give the introspection message if:
	# * The user has it enabled
	# * Has glib already installed
	# * Previous version was different from new version
	if use introspection && has_version "${CATEGORY}/${PN}"; then
		if ! has_version "=${CATEGORY}/${PF}"; then
			ewarn "You must rebuild gobject-introspection so that the installed"
			ewarn "typelibs and girs are regenerated for the new APIs in glib"
		fi
	fi
}

pkg_postinst() {
	# Inform users about possible breakage when updating glib and not dbus-glib, bug #297483
	if has_version dev-libs/dbus-glib; then
		ewarn "If you experience a breakage after updating dev-libs/glib try"
		ewarn "rebuilding dev-libs/dbus-glib"
	fi
}
