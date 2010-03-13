# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/imagemagick/imagemagick-6.5.9.4-r1.ebuild,v 1.1 2010/02/15 19:04:44 ssuominen Exp $

EAPI="2"

inherit eutils multilib perl-app toolchain-funcs versionator

MY_PN=ImageMagick
MY_P=${MY_PN}-${PV%.*}
MY_P2=${MY_PN}-${PV%.*}-${PV#*.*.*.}

DESCRIPTION="A collection of tools and libraries for many image formats"
HOMEPAGE="http://www.imagemagick.org/"
SRC_URI="mirror://imagemagick/${MY_P2}.tar.bz2
		 mirror://imagemagick/legacy/${MY_P2}.tar.bz2"

# perl tests fail with userpriv
RESTRICT="perl? ( userpriv )"
LICENSE="imagemagick"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="autotrace bzip2 +corefonts djvu doc fftw fontconfig fpx graphviz gs hdri
	jbig jpeg jpeg2k lcms lqr nocxx openexr openmp perl png q8 q32 raw
	static-libs svg tiff truetype X wmf xml zlib"

RDEPEND="
	autotrace? ( >=media-gfx/autotrace-0.31.1 )
	bzip2? ( app-arch/bzip2 )
	djvu? ( app-text/djvu )
	fftw? ( sci-libs/fftw )
	fontconfig? ( media-libs/fontconfig )
	fpx? ( media-libs/libfpx )
	graphviz? ( >=media-gfx/graphviz-2.6 )
	gs? ( app-text/ghostscript-gpl )
	jbig? ( media-libs/jbigkit )
	jpeg? ( >=media-libs/jpeg-6b:0 )
	jpeg2k? ( media-libs/jasper )
	lcms? ( >=media-libs/lcms-1.06 )
	lqr? ( >=media-libs/liblqr-0.1.0 )
	openexr? ( media-libs/openexr )
	perl? ( >=dev-lang/perl-5.8.6-r6 )
	png? ( media-libs/libpng )
	raw? ( media-gfx/ufraw )
	tiff? ( >=media-libs/tiff-3.5.5 )
	truetype? ( =media-libs/freetype-2*
		corefonts? ( media-fonts/corefonts ) )
	wmf? ( >=media-libs/libwmf-0.2.8 )
	xml? ( >=dev-libs/libxml2-2.4.10 )
	zlib? ( sys-libs/zlib )
	X? (
		x11-libs/libXext
		x11-libs/libXt
		x11-libs/libICE
		x11-libs/libSM
		svg? ( >=gnome-base/librsvg-2.9.0 )
	)
	!dev-perl/perlmagick
	!media-gfx/graphicsmagick[imagemagick]
	!sys-apps/compare
	>=sys-devel/libtool-1.5.2-r6"

DEPEND="${RDEPEND}
	>=sys-apps/sed-4
	X? ( x11-proto/xextproto )"

S="${WORKDIR}/${MY_P2}"

pkg_setup() {
	# for now, only build svg support when X is enabled, as librsvg
	# pulls in quite some X dependencies.
	if use svg && ! use X ; then
		elog "the svg USE-flag requires the X USE-flag set."
		elog "disabling svg support for now."
	fi

	if use corefonts && ! use truetype ; then
		elog "corefonts USE-flag requires the truetype USE-flag to be set."
		elog "disabling corefonts support for now."
	fi
}

src_prepare() {
	# fix doc dir, bug #91911
	sed -i -e \
		's:DOCUMENTATION_PATH="${DATA_DIR}/doc/${DOCUMENTATION_RELATIVE_PATH}":DOCUMENTATION_PATH="${EPREFIX}/usr/share/doc/${PF}":g' \
		"${S}"/configure || die
}

src_configure() {
	local myconf
	if use q32 ; then
		myconf="${myconf} --with-quantum-depth=32"
	elif use q8 ; then
		myconf="${myconf} --with-quantum-depth=8"
	else
		myconf="${myconf} --with-quantum-depth=16"
	fi

	if use X && use svg ; then
		myconf="${myconf} --with-rsvg"
	else
		myconf="${myconf} --without-rsvg"
	fi

	# openmp support only works with >=sys-devel/gcc-4.3, bug #223825
	if use openmp && version_is_at_least 4.3 $(gcc-version) ; then
		if has_version =sys-devel/gcc-$(gcc-version)*[openmp] ; then
			myconf="${myconf} --enable-openmp"
		else
			elog "disabling openmp support (requires >=sys-devel/gcc-4.3 with USE='openmp')"
			myconf="${myconf} --disable-openmp"
		fi
	else
		elog "disabling openmp support (requires >=sys-devel/gcc-4.3)"
		myconf="${myconf} --disable-openmp"
	fi

	use truetype && myconf="${myconf} $(use_with corefonts windows-font-dir	"${EPREFIX}"/usr/share/fonts/corefonts)"

	econf \
		${myconf} \
		--without-included-ltdl \
		--with-ltdl-include="${EPREFIX}"/usr/include \
		--with-ltdl-lib="${EPREFIX}"/usr/$(get_libdir) \
		--with-threads \
		--with-modules \
		$(use_with perl) \
		--with-perl-options='INSTALLDIRS=vendor' \
		--with-gs-font-dir="${EPREFIX}"/usr/share/fonts/default/ghostscript \
		$(use_enable hdri) \
		$(use_with !nocxx magick-plus-plus) \
		$(use_with autotrace) \
		$(use_with bzip2 bzlib) \
		$(use_with djvu) \
		$(use_with fftw) \
		$(use_with fontconfig) \
		$(use_with fpx) \
		$(use_with gs dps) \
		$(use_with gs gslib) \
		$(use_with graphviz gvc) \
		$(use_with jbig) \
		$(use_with jpeg jpeg) \
		$(use_with jpeg2k jp2) \
		$(use_with lcms) \
		$(use_with openexr) \
		$(use_with png) \
		$(use_enable static-libs static) \
		$(use_with svg rsvg) \
		$(use_with tiff) \
		$(use_with truetype freetype) \
		$(use_with wmf) \
		$(use_with xml) \
		$(use_with zlib) \
		$(use_with X x)
}

src_test() {
	einfo "please note that the tests will only be run when the installed"
	einfo "version and current emerging version are the same"

	if has_version ~${CATEGORY}/${P} ; then
		emake -j1 check || die "make check failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die

	use doc || rm -r "${ED}"/usr/share/doc/${PF}/{www,images,index.html}
	dodoc NEWS.txt ChangeLog AUTHORS.txt README.txt

	# Fix perllocal.pod file collision
	use perl && fixlocalpod
}
