# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/xvid/xvid-1.3.2.ebuild,v 1.9 2012/09/11 06:57:39 vapier Exp $

EAPI=2
inherit flag-o-matic multilib

MY_PN=${PN}core
MY_P=${MY_PN}-${PV}

DESCRIPTION="XviD, a high performance/quality MPEG-4 video de-/encoding solution"
HOMEPAGE="http://www.xvid.org/"
SRC_URI="http://downloads.xvid.org/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="examples +threads pic"

NASM=">=dev-lang/nasm-2"
YASM=">=dev-lang/yasm-1"

DEPEND="amd64? ( || ( ${YASM} ${NASM} ) )
	x86? ( || ( ${YASM} ${NASM} ) )
	x86-fbsd? ( || ( ${YASM} ${NASM} ) )"
RDEPEND=""

S=${WORKDIR}/${MY_PN}/build/generic

src_configure() {
	use sparc && append-cflags -mno-vis #357149

	local myconf
	if use pic || [[ ${ABI} == "x32" ]] ; then #421841
		myconf="--disable-assembly"
	fi

	econf ${myconf} \
		$(use_enable threads pthread)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc "${S}"/../../{AUTHORS,ChangeLog*,CodingStyle,README,TODO}

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
