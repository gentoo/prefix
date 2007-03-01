# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-libs/urt/urt-3.1b-r1.ebuild,v 1.25 2006/05/17 12:42:01 flameeyes Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="the Utah Raster Toolkit is a library for dealing with raster images"
HOMEPAGE="http://www.cs.utah.edu/gdc/projects/urt/"
SRC_URI="ftp://ftp.iastate.edu/pub/utah-raster/${P}.tar.Z"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="gif gs tiff X"

DEPEND="X? ( || ( ( x11-libs/libXext
					x11-proto/xextproto
				)
				virtual/x11
			)
		)
	gif? ( media-libs/giflib )
	tiff? ( media-libs/tiff )
	gs? ( virtual/ghostscript )"

S=${WORKDIR}

urt_config() {
	use $1 && echo "#define $2" || echo "##define $2"
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -f bin/README

	epatch "${FILESDIR}"/${P}-rle-fixes.patch
	epatch "${FILESDIR}"/${P}-compile-updates.patch
	epatch "${FILESDIR}"/${P}-tempfile.patch
	epatch "${FILESDIR}"/${P}-build-fixes.patch
	epatch "${FILESDIR}/${P}-make.patch"

	# punt bogus manpage #109511
	rm -f man/man1/template.1

	# stupid OS X declares a stack_t type already #107428
	sed -i -e 's:stack_t:_urt_stack:g' tools/clock/rleClock.c || die

	sed -i -e '/^CFLAGS/s: -O : :' makefile.hdr
	cp "${FILESDIR}"/gentoo-config config/gentoo
	cat >> config/gentoo <<-EOF
	$(urt_config X X11)
	$(urt_config gs POSTSCRIPT)
	$(urt_config tiff TIFF)
	ExtraCFLAGS = ${CFLAGS}
	MFLAGS = ${MAKEOPTS}
	# prevent circular depend #111455
	$(has_version media-libs/giflib && urt_config gif GIF)
	EOF
}

src_compile() {
	./Configure config/gentoo || die "config"
	emake CC=$(tc-getCC) || die "emake"
}

src_install() {
	# this just installs it into some local dirs
	make install || die
	dobin bin/* || die "dobin"
	dolib.a lib/librle.a || die "dolib.a"
	insinto /usr/include
	doins include/rle*.h || die "doins include"
	doman man/man?/*.[135]
	dodoc *-changes CHANGES* README blurb
}
