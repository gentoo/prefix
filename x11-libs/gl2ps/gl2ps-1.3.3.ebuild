# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gl2ps/gl2ps-1.3.3.ebuild,v 1.1 2009/04/07 18:41:50 bicatali Exp $

EAPI=2
inherit eutils toolchain-funcs multilib

DESCRIPTION="OpenGL to PostScript printing library"
HOMEPAGE="http://www.geuz.org/gl2ps/"
SRC_URI="http://geuz.org/${PN}/src/${P}.tgz"
LICENSE="LGPL-2"
SLOT="0"
IUSE="doc"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

RDEPEND="virtual/glut"
DEPEND="${RDEPEND}"

src_compile() {
	$(tc-getCC) ${CFLAGS} -fPIC -c gl2ps.c -o gl2ps.o \
		|| die "compiling gl2ps failed"
	if [[ ${CHOST} == *-darwin* ]] ; then
		# doin' things the Mach-O way
		$(tc-getCC) -dynamiclib ${LDFLAGS} \
			-Wl,-install_name,"${EPREFIX}/usr/$(get_libdir)/libgl2ps.1.dylib" \
			gl2ps.o -o libgl2ps.1.dylib -lm -lGL -lGLU -lglut \
			|| die "linking libgl2ps failed"
	else
	$(tc-getCC) -shared ${LDFLAGS} -Wl,-soname,libgl2ps.so.1 \
		gl2ps.o -o libgl2ps.so.1 -lm -lGL -lGLU -lglut \
		|| die "linking libgl2ps failed"
	fi
}

src_install () {
	dolib.so libgl2ps$(get_libname 1) || die
	dosym libgl2ps$(get_libname 1) /usr/$(get_libdir)/libgl2ps$(get_libname)
	insinto /usr/include
	doins gl2ps.h || die
	dodoc TODO
	insinto /usr/share/doc/${PF}
	if use doc; then
		doins gl2psTest* *.pdf || die
	fi
}
