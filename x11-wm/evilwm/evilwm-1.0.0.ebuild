# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/evilwm/evilwm-1.0.0.ebuild,v 1.5 2008/07/18 07:12:37 aballier Exp $

inherit toolchain-funcs multilib

DESCRIPTION="A minimalist, no frills window manager for X."
SRC_URI="http://www.6809.org.uk/evilwm/${P}.tar.gz"
HOMEPAGE="http://evilwm.sourceforge.net"

IUSE=""
SLOT="0"
LICENSE="as-is"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc64-solaris"

RDEPEND="x11-libs/libXext
	x11-libs/libXrandr"

DEPEND="${RDEPEND}
	x11-proto/xextproto
	x11-proto/xproto"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i 's/^#define DEF_FONT.*/#define DEF_FONT "fixed"/' evilwm.h \
		|| die "sed font failed"
	sed -i -e '/^CFLAGS/s/ -Os/ /' \
		-e 's/install -s /install /' Makefile || die "sed opt failed"
}

src_compile() {
	emake CC="$(tc-getCC)" prefix="\$(DESTDIR)/${EPREFIX}/usr" XROOT="${EPREFIX}/usr" LDPATH="-L${EPREFIX}/usr/$(get_libdir)" || die
}

src_install () {
	make DESTDIR="${D}" prefix="\$(DESTDIR)/${EPREFIX}/usr" install || die "make install failed"

	dodoc ChangeLog README TODO || die "dodoc failed"

	echo -e "#!${EPREFIX}/bin/sh\n${EPREFIX}/usr/bin/${PN}" > "${T}/${PN}"
	exeinto /etc/X11/Sessions
	doexe "${T}/${PN}" || die "/etc/X11/Sessions failed"

	insinto /usr/share/xsessions
	doins "${FILESDIR}/${PN}.desktop" || die "${PN}.desktop failed."
}
