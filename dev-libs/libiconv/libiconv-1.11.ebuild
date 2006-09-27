# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.11.ebuild,v 1.5 2006/08/05 13:19:36 dertobi123 Exp $

EAPI="prefix"

inherit eutils multilib flag-o-matic autotools libtool

DESCRIPTION="GNU charset conversion library for libc which doesn't implement it"
SRC_URI="mirror://gnu/libiconv/${P}.tar.gz"
HOMEPAGE="http://www.gnu.org/software/libiconv/"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE="build"

DEPEND="!sys-libs/glibc"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# This patch is needed as libiconv 1.10 provides (and uses) new functions
	# and they are not present in the old libiconv.so, and this breaks the
	# ${DESTDIR} != ${prefix} that we use. It's a problem for Solaris, but we
	# don't have to deal with it for now.
	epatch "${FILESDIR}/${PN}-1.10-link.patch"

	# Make sure that libtool support is updated to link "the linux way" on
	# FreeBSD.
	elibtoolize
}

src_compile() {
	# Filter -static as it breaks compilation
	filter-ldflags -static

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
	emake DESTDIR="${EDEST}" docdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "make install failed"

	# Move static libs and creates ldscripts into /usr/lib
	dodir /$(get_libdir)
	if [[ ${USERLAND} != "Darwin" ]] ; then
		mv "${D}"/usr/$(get_libdir)/*.so* "${D}/$(get_libdir)"
		gen_usr_ldscript libiconv$(get_libname)
		gen_usr_ldscript libcharset$(get_libname)
	fi

	use build && rm -rf "${D}/usr"

	preserve_old_lib /lib/$(get_libdir)/libiconv$(get_libname 4)
	# config protect
	rm "${D}"/usr/lib/charset.alias
}

pkg_postinst() {
	preserve_old_lib_notify /lib/$(get_libdir)/libiconv$(get_libname 4)
}
