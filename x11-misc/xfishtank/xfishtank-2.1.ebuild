# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xfishtank/xfishtank-2.1.ebuild,v 1.12 2006/10/21 22:24:31 omp Exp $

inherit eutils toolchain-funcs

MY_P=${P}tp

DESCRIPTION="Turns your root window into an aquarium."
HOMEPAGE="http://www.ibiblio.org/pub/Linux/X11/demos/"
SRC_URI="http://www.ibiblio.org/pub/Linux/X11/demos/${MY_P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86-linux ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto
	x11-misc/makedepend"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/${MY_P}-Makefile.patch"
	[[ ${CHOST} == *-winnt* ]] && epatch "${FILESDIR}/${MY_P}-winnt.patch"
}

src_compile() {
	makedepend || die "makedepend failed"
	emake CC=$(tc-getCC) CXX=$(tc-getCXX) || die "emake failed"
}

src_install() {
	local exeext=
	[[ ${CHOST} == *-winnt* ]] && exeext=.exe

	dobin xfishtank$exeext
	dodoc README README.Linux README.TrueColor README.Why.2.1tp
}
