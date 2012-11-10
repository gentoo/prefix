# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gd/gd-2.0.35-r3.ebuild,v 1.18 2012/05/05 08:02:43 jdhore Exp $

EAPI="2"

inherit autotools eutils flag-o-matic

DESCRIPTION="A graphics library for fast image creation"
HOMEPAGE="http://libgd.org/ http://www.boutell.com/gd/"
SRC_URI="http://libgd.org/releases/${P}.tar.bz2"

LICENSE="as-is BSD"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="fontconfig jpeg png static-libs truetype xpm zlib"

RDEPEND="fontconfig? ( media-libs/fontconfig )
	jpeg? ( virtual/jpeg )
	png? ( >=media-libs/libpng-1.2:0 )
	truetype? ( >=media-libs/freetype-2.1.5 )
	xpm? ( x11-libs/libXpm x11-libs/libXt )
	zlib? ( sys-libs/zlib )
	x86-interix? ( sys-devel/gettext )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-libpng14.patch #305101
	epatch "${FILESDIR}"/${P}-maxcolors.patch #292130
	epatch "${FILESDIR}"/${P}-fontconfig.patch #363367
	epatch "${FILESDIR}"/${P}-libpng-pkg-config.patch

	# Avoid programs we never install
	local make_sed=( -e '/^noinst_PROGRAMS/s:noinst:check:' )
	use png || make_sed+=( -e '/_PROGRAMS/s:(gdparttopng|gdtopng|gd2topng|pngtogd|pngtogd2|webpng)::g' )
	use zlib || make_sed+=( -e '/_PROGRAMS/s:(gd2topng|gd2copypal|gd2togif|giftogd2|gdparttopng|pngtogd2)::g' )
	sed -i -r "${make_sed[@]}" Makefile.am || die

	cat <<-EOF > acinclude.m4
	m4_ifndef([AM_ICONV],[m4_define([AM_ICONV],[:])])
	EOF

	# also needed for new libtool for interix
	eautoreconf
}

src_configure() {
	# setup a default FONT path that has a chance of existing using corefonts,
	# as to make it more useful with e.g. gnuplot
	local fontpath="${EPREFIX}/usr/share/fonts/corefonts"
	# like with fontconfig, try to use fonts from the host OS, because that's
	# beneficial for the user
	use prefix && case ${CHOST} in
		*-darwin*)
			fontpath="${fontpath}:/Library/Fonts:/System/Library/Fonts"
		;;
		*-solaris*)
			[[ -d /usr/X/lib/X11/fonts/TrueType ]] && \
				fontpath="${fontpath}:/usr/X/lib/X11/fonts/TrueType"
			[[ -d /usr/X/lib/X11/fonts/Type1 ]] && \
				fontpath="${fontpath}:/usr/X/lib/X11/fonts/Type1"
			# OpenIndiana
			[[ -d /usr/share/fonts/X11/Type1 ]] && \
				fontpath="${fontpath}:/usr/share/fonts/X11/Type1"
		;;
		*-linux-gnu)
			[[ -d /usr/share/fonts/truetype ]] && \
				fontpath="${fontpath}:/usr/share/fonts/truetype"
		;;
	esac
	append-flags "-DDEFAULT_FONTPATH=\\\"${fontpath}\\\""

	export ac_cv_lib_z_deflate=$(usex zlib)
	# we aren't actually {en,dis}abling X here ... the configure
	# script uses it just to add explicit -I/-L paths which we
	# don't care about on Gentoo systems.
	econf \
		--without-x \
		$(use_enable static-libs static) \
		$(use_with fontconfig) \
		$(use_with png) \
		$(use_with truetype freetype) \
		$(use_with jpeg) \
		$(use_with xpm)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc INSTALL README*
	dohtml -r ./
	use static-libs || rm -f "${ED}"/usr/*/libgd.la
}
