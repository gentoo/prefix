# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/glib/glib-2.14.6.ebuild,v 1.7 2008/02/10 22:12:27 tester Exp $

EAPI="prefix"

inherit gnome.org libtool eutils flag-o-matic autotools

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="http://www.gtk.org/"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="debug doc hardened elibc_glibc"

RDEPEND="virtual/libc
	virtual/libiconv"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.16
	>=sys-devel/gettext-0.11
	doc? (
		>=dev-util/gtk-doc-1.4
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

	# freebsd: elibtoolize would suffice
	# interix: need recent libtool
	# but doing eautoreconf needs gtk-doc.m4.
	# To avoid hard dependency on gtk-doc, provide gtk-doc.m4 in ${FILESDIR}/m4
	AT_M4DIR="m4macros ${FILESDIR}/m4" eautoreconf 
}

src_compile() {
	epunt_cxx

	local myconf

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
	econf \
		$(use_enable doc gtk-doc) \
		${myconf} \
		--with-threads=posix \
		--enable-static || die "configure failed"

	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "Installation failed"

	# Do not install charset.alias even if generated, leave it to libiconv
	rm -f "${ED}/usr/lib/charset.alias"

	dodoc AUTHORS ChangeLog* NEWS* README
}
