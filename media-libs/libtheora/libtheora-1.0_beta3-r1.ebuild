# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libtheora/libtheora-1.0_beta3-r1.ebuild,v 1.1 2008/05/11 21:13:33 aballier Exp $

EAPI="prefix"

inherit autotools eutils toolchain-funcs flag-o-matic

DESCRIPTION="The Theora Video Compression Codec"
HOMEPAGE="http://www.theora.org"
SRC_URI="http://downloads.xiph.org/releases/theora/${P/_}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc encode examples"

RDEPEND="media-libs/libogg
	encode? ( media-libs/libvorbis )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-util/pkgconfig"

S=${WORKDIR}/${P/_}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.0_beta2-flags.patch
	epatch "${FILESDIR}"/${P}-pic-fix.patch
	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	use x86 && filter-flags -fforce-addr -frename-registers #200549
	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"

	# Don't build specs even with doc enabled, just a few people would need
	# it and causes sandbox violations.
	export ac_cv_prog_HAVE_PDFLATEX="false"

	econf --disable-dependency-tracking --disable-examples \
		--disable-sdltest $(use_enable encode)

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" docdir="${EPREFIX#/}/usr/share/doc/${PF}" \
		install || die "emake install failed."

	dodoc AUTHORS CHANGES README

	prepalldocs

	if use examples; then
		rm examples/Makefile*
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi

	dodoc README
}
