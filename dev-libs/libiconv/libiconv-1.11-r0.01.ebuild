# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.11.ebuild,v 1.8 2007/01/23 07:17:54 flameeyes Exp $

EAPI="prefix"

inherit eutils multilib flag-o-matic toolchain-funcs autotools

DESCRIPTION="GNU charset conversion library for libc which doesn't implement it"
SRC_URI="mirror://gnu/libiconv/${P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/libiconv/"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="build"

DEPEND="!sys-libs/glibc
	!sys-apps/man-pages"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# This patch is needed as libiconv 1.10 provides (and uses) new functions
	# and they are not present in the old libiconv.so, and this breaks the
	# ${DESTDIR} != ${prefix} that we use. It's a problem for Solaris, but we
	# don't have to deal with it for now.
	epatch "${FILESDIR}/${PN}-1.10-link.patch"

	# Make sure that libtool support is updated to link "the linux way" on
	# FreeBSD. elibtoolize would be sufficient here, but
	# we explicitly want the installed libtool, since thats the only one thats
	# capable of everything we need, especially shared libs on interix.
	cp "${EPREFIX}"/usr/share/aclocal/libtool.m4 m4/libtool.m4
	cp "${EPREFIX}"/usr/share/aclocal/libtool.m4 libcharset/m4/libtool.m4

	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	# Filter -static as it breaks compilation
	filter-ldflags -static

	# In Prefix we want to have the same header declaration on every
	# platform, so make configure find that it should do
	# "const char * *inbuf"
	export am_cv_func_iconv=no

	# Install in /lib as utils installed in /lib like gnutar
	# can depend on this

	# Disable NLS support because that creates a circular dependency
	# between libiconv and gettext

	econf \
		--disable-nls \
		--enable-shared \
		--enable-static \
		 || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" docdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "make install failed"

	# Move static libs and creates ldscripts into /usr/lib
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/lib{charset,iconv}*$(get_libname)* "${ED}/$(get_libdir)" #210239
	gen_usr_ldscript libiconv$(get_libname)
	gen_usr_ldscript libcharset$(get_libname)

	use build && rm -rf "${ED}/usr"

	keep_aix_runtime_objects /usr/lib/libiconv.a "/usr/lib/libiconv.a(shr4.o)"
}
