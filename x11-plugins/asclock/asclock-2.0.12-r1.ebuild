# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-plugins/asclock/asclock-2.0.12-r1.ebuild,v 1.5 2006/12/08 00:01:45 drizzt Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

IUSE=""
DESCRIPTION="Clock applet for AfterStep"
SRC_URI="http://www.tigr.net/afterstep/download/asclock/${P}.tar.gz"
HOMEPAGE="http://www.tigr.net/afterstep/list.pl"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="x11-libs/libXpm"
RDEPEND="${DEPEND}
	x11-proto/xextproto
	x11-proto/xproto"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-gcc41.patch
	ln -s themes/classic default_theme
}

src_compile() {
	local x
	for x in asclock parser symbols config
	do
		$(tc-getCC) \
			    ${CFLAGS} \
			    -I/usr/include \
			    -Dlinux -D__i386__ \
			    -D_POSIX_C_SOURCE=199309L \
			    -D_POSIX_SOURCE \
			    -D_XOPEN_SOURCE \
			    -D_BSD_SOURCE \
			    -D_SVID_SOURCE \
			    -DFUNCPROTO=15 \
			    -DNARROWPROTO \
			    -c -o ${x}.o ${x}.c || die "compile failed"
	done
	$(tc-getCC) \
		    ${CFLAGS} \
		    -o asclock \
		    asclock.o parser.o symbols.o config.o \
		    -L"${EPREFIX}"/usr/lib \
		    -L"${EPREFIX}"/usr/lib/X11 \
		    -lXpm -lXext -lX11 || die "compile asclock failed"
}

src_install() {
	dobin asclock
	local themesdir="/usr/share/${PN}/themes"
	insinto ${themesdir}
	doins -r themes/*
	dodoc README README.THEMES TODO
	cd "${ED}/${themesdir}"
	rm -f Freeamp/Makefile{,.*}
	ln -s classic default_theme
}
