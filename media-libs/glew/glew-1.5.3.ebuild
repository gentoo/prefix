# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glew/glew-1.5.3.ebuild,v 1.1 2010/04/21 09:09:35 ssuominen Exp $

EAPI=2
inherit multilib toolchain-funcs

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tgz"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="x11-libs/libXmu
	x11-libs/libXi
	virtual/glu
	virtual/opengl
	x11-libs/libXext
	x11-libs/libX11"

src_prepare() {
	sed -i \
		-e '/INSTALL/s:-s::' \
		-e '/$(CC) $(CFLAGS) -o/s:$(CFLAGS):$(CFLAGS) $(LDFLAGS):' \
		Makefile || die
	# for Prefix
	sed -i -e '/^LDFLAGS.EXTRA/d' config/Makefile.linux || die
	# don't do stupid Solaris specific stuff that won't work in Prefix
	cp config/Makefile.linux config/Makefile.solaris || die
}

src_compile(){
	emake AR="$(tc-getAR)" STRIP=true CC="$(tc-getCC)" \
		LD="$(tc-getCC) ${LDFLAGS}" POPT="${CFLAGS}" M_ARCH="" || die
}

src_install() {
	dodir /usr/$(get_libdir)/pkgconfig

	emake STRIP=true GLEW_DEST="${ED}/usr" LIBDIR="${ED}/usr/$(get_libdir)" \
		M_ARCH="" install || die

	dodoc doc/*.txt README.txt TODO.txt || die
	dohtml doc/*.{css,html,jpg,png} || die
}
