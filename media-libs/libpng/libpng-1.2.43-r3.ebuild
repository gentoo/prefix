# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.2.43-r3.ebuild,v 1.1 2010/05/13 20:05:17 ssuominen Exp $

# this ebuild is only for the libpng12.so.0 SONAME for ABI compat

EAPI=3
inherit multilib libtool autotools

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
SLOT="1.2"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="sys-libs/zlib
	!<media-libs/libpng-1.2.43-r3"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

pkg_setup() {
	if [[ -e ${EROOT}/usr/$(get_libdir)/libpng12$(get_libname 0) ]]; then
		rm -f "${EROOT}"/usr/$(get_libdir)/libpng12$(get_libname 0)
	fi
}

src_prepare() {
	# required to get new/patched libtool, which knows better about eprefix!
	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-static
}

src_install() {
	exeinto /usr/$(get_libdir)
	newexe .libs/libpng12$(get_libname 0.43.0) libpng12$(get_libname 0) || die
}
