# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/glew/glew-1.5.1.ebuild,v 1.4 2009/05/02 22:59:11 solar Exp $

inherit eutils multilib toolchain-funcs

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tgz"

LICENSE="BSD GLX SGI-B GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND="virtual/opengl
	virtual/glu"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	edos2unix config/config.guess Makefile
	sed -i \
		-e 's:-s\b::g' \
		-e '95s:$(CFLAGS):& $(LDFLAGS):' \
		-e '98s:$(CFLAGS):& $(LDFLAGS):' \
		Makefile || die "sed failed"
	# for Prefix
	sed -i -e '/^LDFLAGS.EXTRA/d' config/Makefile.linux || die
	# don't do stupid Solaris specific stuff that won't work in Prefix
	cp config/Makefile.linux config/Makefile.solaris || die
}

src_compile(){
	emake STRIP=true LD="$(tc-getCC) ${LDFLAGS}" CC="$(tc-getCC)" \
		POPT="${CFLAGS}" M_ARCH="" AR="$(tc-getAR)" \
		|| die "emake failed"
}

src_install() {
	emake STRIP=true GLEW_DEST="${ED}/usr" LIBDIR="${ED}/usr/$(get_libdir)" \
		M_ARCH="" install || die "emake install failed"

	dodoc README.txt
	dohtml doc/*.{html,css,png,jpg}
}
