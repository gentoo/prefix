# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit flag-o-matic eutils fixheadtails autotools

MY_P=${PN}core-${PV/_beta/-beta}
DESCRIPTION="XviD, a high performance/quality MPEG-4 video de-/encoding solution"
HOMEPAGE="http://www.xvid.org/"
SRC_URI="http://downloads.xvid.org/downloads/${MY_P}.tar.bz2
	mirror://gentoo/${PN}-1.1.2-noexec-stack.patch.bz2"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="doc altivec"

DEPEND="x86? ( >=dev-lang/nasm-0.98.36 )
	amd64? ( >=dev-lang/yasm-0.5.0 )"
RDEPEND=""

S=${WORKDIR}/${MY_P}/build/generic

src_unpack() {
	unpack ${A}

	cd "${WORKDIR}"/${MY_P}
	epatch "${FILESDIR}"/${PN}-1.1.0_beta2-altivec.patch
	epatch "${WORKDIR}"/${PN}-1.1.2-noexec-stack.patch
	epatch "${FILESDIR}"/${PN}-1.1.0-3dnow-2.patch

	cd "${S}"
	eautoreconf
}

src_compile() {
	# fafhrd: this builds a mac osx bundle, AFAICT
	#econf $(use_enable altivec) --enable-macosx_module || die "econf failed"
	
	# fafhrd: This builds the assmebly optimized stuff, but fails to link
	#econf $(use_enable altivec) || die "econf failed"
	#sed -e "s:^AFLAGS.*$:AFLAGS=-I\$(<D)/ -f macho:" platform.inc > platform.inc.temp
	#mv platform.inc.temp platform.inc

	# fafhrd: this disables assembly and makes baby jesus cry
	econf $(use_enable altivec) --disable-assembly || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die

	cd "${S}"/../../
	dodoc AUTHORS ChangeLog README TODO doc/*

	if [[ ${CHOST} == *-darwin* ]]; then
		local mylib=$(basename $(ls "${ED}"/usr/$(get_libdir)/libxvidcore.*.dylib))
		dosym ${mylib} /usr/$(get_libdir)/libxvidcore.dylib
	else
		local mylib=$(basename $(ls "${ED}"/usr/$(get_libdir)/libxvidcore.so*))
		dosym ${mylib} /usr/$(get_libdir)/libxvidcore.so
		dosym ${mylib} /usr/$(get_libdir)/${mylib/.1}
	fi

	if use doc ; then
		dodoc CodingStyle doc/README
		docinto examples
		dodoc examples/*
	fi
}
