# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/glib-2.16.1.ebuild,v 1.1 2008/03/11 03:27:20 leio Exp $

EAPI="prefix"

inherit gnome.org libtool eutils flag-o-matic

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="debug doc fam hardened selinux xattr"

RDEPEND="virtual/libc
		 virtual/libiconv
		 xattr? ( sys-apps/attr )
		 fam? ( virtual/fam )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.16
		>=sys-devel/gettext-0.11
		doc?	(
					>=dev-libs/libxslt-1.0
					>=dev-util/gtk-doc-1.8
					~app-text/docbook-xml-dtd-4.1.2
				)"

src_unpack() {
	unpack ${A}
	cd "${S}"

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

	epatch "${FILESDIR}"/${PN}-2.12.11-solaris-thread.patch
	# autoreconf is not going to work, as we miss some m4 includes

	sed -e "s/MATCH_LIMIT_RECURSION=10000000/MATCH_LIMIT_RECURSION=8192/g" \
		-i "${S}/glib/pcre/Makefile.in" "${S}/glib/pcre/Makefile.am"

	# Fix gmodule issues on fbsd; bug #184301
	epatch "${FILESDIR}"/${PN}-2.12.12-fbsd.patch

	# add support for reading file systems on interix.
	epatch "${FILESDIR}"/${P}-interix.patch

	# freebsd: elibtoolize would suffice
	# interix: need recent libtool
	# but doing eautoreconf needs gtk-doc.m4.
	# To avoid hard dependency on gtk-doc, provide gtk-doc.m4 in ${FILESDIR}/m4
	AT_M4DIR="m4macros ${FILESDIR}/m4" eautoreconf 
}

src_compile() {
	local myconf

	epunt_cxx

	# Building with --disable-debug highly unrecommended.  It will build glib in
	# an unusable form as it disables some commonly used API.  Please do not
	# convert this to the use_enable form, as it results in a broken build.
	# -- compnerd (3/27/06)
	use debug && myconf="--enable-debug"

	# non-glibc platforms use GNU libiconv, but configure needs to know about
	# that not to get confused when it finds something outside the prefix too
	use elibc_glibc || myconf="${myconf} --with-libiconv=gnu"

	[[ ${CHOST} == *-interix* ]] && {
		append-flags "-D_ALL_SOURCE"
		export ac_cv_func_mmap_fixed_mapped=yes
		export ac_cv_func_poll=no
	}

	# always build static libs, see #153807
	econf ${myconf}                 \
		  $(use_enable xattr)       \
		  $(use_enable doc man)     \
		  $(use_enable doc gtk-doc) \
		  $(use_enable fam)         \
		  $(use_enable selinux)     \
		  --enable-static           \
		  --with-threads=posix || die "configure failed"

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${ED}/usr/lib/charset.alias"

	dodoc AUTHORS ChangeLog* NEWS* README
}
