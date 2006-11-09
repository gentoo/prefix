# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/portaudio/portaudio-18.1-r5.ebuild,v 1.1 2006/10/22 14:53:15 aballier Exp $

EAPI="prefix"

inherit toolchain-funcs

MY_P=${PN}_v${PV/./_}
DESCRIPTION="An open-source cross platform audio API."
HOMEPAGE="http://www.portaudio.com"
SRC_URI="http://www.portaudio.com/archives/${MY_P}.zip"

LICENSE="GPL-2"
SLOT="18"
KEYWORDS="~ppc-macos"
IUSE=""

RDEPEND=""
DEPEND="app-arch/unzip"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}

	if [[ ${USERLAND} == "Darwin" ]] ; then
		cp "${FILESDIR}"/${P}-Makefile.macos "${S}"/Makefile
	else
		cp "${FILESDIR}"/${PF}-Makefile.linux "${S}"/Makefile
	fi
}

src_compile() {
	emake CC="$(tc-getCC)" AR="$(tc-getAR)" RANLIB="$(tc-getRANLIB)" LD="$(tc-getLD)" CFLAGS="${CFLAGS}" || die
}

src_install() {
	make DESTDIR="${D}" includedir="${EPREFIX}/usr/include" libdir="${EPREFIX}/usr/$(get_libdir)" install || die
	fperms 644 /usr/include/portaudio/portaudio.h
	dodoc docs/*
}
