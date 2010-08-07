# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-wm/evilwm/evilwm-1.1.0_pre8.ebuild,v 1.3 2010/07/06 21:09:11 ssuominen Exp $

EAPI=2
inherit toolchain-funcs

MY_P=${P/_}

DESCRIPTION="A minimalist, no frills window manager for X."
HOMEPAGE="http://www.6809.org.uk/evilwm/"
SRC_URI="http://www.6809.org.uk/${PN}/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
#KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc64-solaris"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXrandr
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto"

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i \
		-e 's/^#define DEF_FONT.*/#define DEF_FONT "fixed"/' \
		evilwm.h || die

	sed -i -e '/Encoding/d' ${PN}.desktop || die
}

src_compile() {
	emake CC="$(tc-getCC)" prefix="\$(DESTDIR)/${EPREFIX}/usr" || die
}

src_install() {
	emake DESTDIR="${D}" prefix="\$(DESTDIR)/${EPREFIX}/usr" INSTALL_STRIP="" install || die
	dodoc ChangeLog README TODO || die

	echo ${PN} > "${T}"/${PN}
	exeinto /etc/X11/Sessions
	doexe "${T}"/${PN} || die
}
