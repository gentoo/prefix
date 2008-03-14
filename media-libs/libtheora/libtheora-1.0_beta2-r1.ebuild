# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libtheora/libtheora-1.0_beta2-r1.ebuild,v 1.8 2008/03/13 09:37:38 corsair Exp $

EAPI="prefix"

inherit autotools eutils toolchain-funcs flag-o-matic

DESCRIPTION="The Theora Video Compression Codec"
HOMEPAGE="http://www.theora.org"
SRC_URI="http://downloads.xiph.org/releases/theora/${P/_}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc encode examples"

RDEPEND=">=media-libs/libogg-1.1
	encode? ( >=media-libs/libvorbis-1.0.1 )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-util/pkgconfig"

S=${WORKDIR}/${P/_}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-flags.patch
	epatch "${FILESDIR}"/${P}-pic-fix.patch
	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	# Hardened still uses gcc-3.4, bug #200549
	if [[ $(gcc-version) == 3.4 ]] ; then
		ewarn "-fforce-addr -frename-registers flags are filtered"
		filter-flags -fforce-addr -frename-registers
	fi
	local myconf

	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"

	econf --disable-dependency-tracking --disable-examples \
		--disable-sdltest $(use_enable encode) ${myconf}

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
