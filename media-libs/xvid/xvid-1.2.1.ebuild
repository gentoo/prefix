# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/xvid/xvid-1.2.1.ebuild,v 1.3 2009/02/11 19:35:19 aballier Exp $

inherit eutils fixheadtails

MY_PN="${PN}core"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="XviD, a high performance/quality MPEG-4 video de-/encoding solution"
HOMEPAGE="http://www.xvid.org"
SRC_URI="http://downloads.xvid.org/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="examples altivec"

NASM=">=dev-lang/nasm-2.04"
DEPEND="x86? ( ${NASM} )
	amd64? ( ${NASM} )
	x86-fbsd? ( ${NASM} )"
RDEPEND=""

S="${WORKDIR}/${MY_PN}/build/generic"

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"/${MY_PN}
	epatch "${FILESDIR}"/${P}-ncpu.patch
}

src_compile() {
	econf $(use_enable altivec)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	dodoc "${S}"/../../{AUTHORS,ChangeLog*,README,TODO}

	if [[ ${CHOST} == *-darwin* ]]; then
		local mylib=$(basename $(ls "${ED}"/usr/$(get_libdir)/libxvidcore.*.dylib))
		dosym ${mylib} /usr/$(get_libdir)/libxvidcore.dylib
	else
		local mylib=$(basename $(ls "${ED}"/usr/$(get_libdir)/libxvidcore.so*))
		dosym ${mylib} /usr/$(get_libdir)/libxvidcore.so
		dosym ${mylib} /usr/$(get_libdir)/${mylib%.?}
	fi

	if use examples; then
		dodoc "${S}"/../../CodingStyle
		insinto /usr/share/${PN}
		doins -r "${S}"/../../examples
	fi
}
