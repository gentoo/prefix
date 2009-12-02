# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/graphicsmagick/graphicsmagick-1.3.7.ebuild,v 1.1 2009/11/24 00:20:48 bicatali Exp $

EAPI="2"

inherit toolchain-funcs flag-o-matic perl-app

MY_P=${P/graphicsm/GraphicsM}

DESCRIPTION="Collection of tools and libraries for many image formats"
HOMEPAGE="http://www.graphicsmagick.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="bzip2 cxx debug fpx -gs imagemagick jbig +jpeg +jpeg2k lcms openmp
	perl +png q16 q32 +svg +threads tiff +truetype X wmf zlib"

RDEPEND="bzip2? ( app-arch/bzip2 )
	fpx? ( media-libs/libfpx )
	gs? ( virtual/ghostscript )
	jbig? ( media-libs/jbigkit )
	jpeg? ( media-libs/jpeg )
	jpeg2k? ( >=media-libs/jasper-1.701.0 )
	lcms? ( media-libs/lcms )
	perl? ( dev-lang/perl )
	png? ( media-libs/libpng )
	svg? ( dev-libs/libxml2 )
	tiff? ( >=media-libs/tiff-3.8.2 )
	truetype? ( >=media-libs/freetype-2.0 )
	wmf? ( media-libs/libwmf )
	X? ( x11-libs/libXext
		x11-libs/libSM
		x11-libs/libX11
		x11-libs/libICE )
	imagemagick? ( !media-gfx/imagemagick )"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use openmp &&
		[[ $(tc-getCC)$ == *gcc* ]] &&
		( [[ $(gcc-major-version)$(gcc-minor-version) -lt 42 ]] ||
			! built_with_use sys-devel/gcc openmp )
	then
		ewarn "You are using gcc and OpenMP is only available with gcc >= 4.2 "
		ewarn "If you want to build fftw with OpenMP, abort now,"
		ewarn "and switch CC to an OpenMP capable compiler"
		epause 5
	fi
}

src_configure() {
	local quantumDepth
	if use q16 ; then
		quantumDepth="16"
	elif use q32 ; then
		quantumDepth="32"
	else
		quantumDepth="8"
	fi

	use debug && filter-flags -fomit-frame-pointer

	econf \
		--enable-shared \
		--enable-largefile \
		--without-included-ltdl \
		--without-frozenpaths \
		--with-modules \
		--with-quantum-depth=${quantumDepth} \
		$(use_enable debug ccmalloc) \
		$(use_enable debug prof) \
		$(use_enable debug gcov) \
		$(use_enable imagemagick magick-compat) \
		$(use_enable openmp) \
		$(use_with bzip2 bzlib) \
		$(use_with cxx magick-plus-plus) \
		$(use_with fpx) \
		$(use_with gs gslib) \
		$(use_with jbig) \
		$(use_with jpeg) \
		$(use_with jpeg2k jp2) \
		$(use_with lcms) \
		$(use_with perl) \
		$(use_with png) \
		$(use_with svg xml) \
		$(use_with threads) \
		$(use_with tiff) \
		$(use_with truetype ttf) \
		$(use_with wmf) \
		$(use_with X x) \
		$(use_with zlib)
}

src_test() {
	emake check || die "tests failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"
	dodoc README.txt ChangeLog* NEWS.txt TODO.txt

	# Fix perllocal.pod file collision
	use perl && fixlocalpod
}

pkg_postinst() {
	elog "For RAW image suport please install media-gfx/dcraw."
	elog "For mpeg suport please install media-video/mpeg2vidcodec."
	elog "To read gnuplot files please install sci-visualization/gnuplot."
}
