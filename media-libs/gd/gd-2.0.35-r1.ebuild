# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/gd/gd-2.0.35-r1.ebuild,v 1.9 2010/03/08 20:14:28 ssuominen Exp $

inherit autotools prefix flag-o-matic

DESCRIPTION="A graphics library for fast image creation"
HOMEPAGE="http://libgd.org/"
SRC_URI="http://libgd.org/releases/${P}.tar.bz2"

LICENSE="|| ( as-is BSD )"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="fontconfig jpeg png truetype xpm"

RDEPEND="fontconfig? ( media-libs/fontconfig )
	jpeg? ( >=media-libs/jpeg-6b )
	png? ( >=media-libs/libpng-1.2.5 sys-libs/zlib )
	truetype? ( >=media-libs/freetype-2.1.5 )
	xpm? ( x11-libs/libXpm x11-libs/libXt )
	x86-interix? ( sys-devel/gettext )"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-libpng14.patch \
		"${FILESDIR}"/${P}-maxcolors.patch

	# need new libtool for interix
	[[ ${CHOST} == *-interix* ]] \
		&& eautoreconf \
		|| eautoconf
	find . -type f -print0 | xargs -0 touch -r configure

	epatch "${FILESDIR}"/${PN}-prefix.patch
	eprefixify bdftogd
}

src_compile() {
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
		;;
		*-linux-gnu)
			[[ -d /usr/share/fonts/truetype ]] && \
				fontpath="${fontpath}:/usr/share/fonts/truetype"
		;;
	esac
	append-flags "-DDEFAULT_FONTPATH=\\\"${fontpath}\\\""

	econf \
		$(use_with fontconfig) \
		$(use_with png) \
		$(use_with truetype freetype) \
		$(use_with jpeg) \
		$(use_with xpm) \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc INSTALL README*
	dohtml -r ./
}
