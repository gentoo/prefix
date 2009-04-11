# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/links/links-2.2.ebuild,v 1.8 2008/12/07 11:49:36 vapier Exp $

WANT_AUTOCONF=latest
WANT_AUTOMAKE=none

inherit eutils toolchain-funcs autotools

DESCRIPTION="links is a fast lightweight text and graphic web-browser"
HOMEPAGE="http://links.twibright.com/"
# To handle pre-version ...
MY_P="${P/_/}"
S="${WORKDIR}/${MY_P}"
SRC_URI="http://links.twibright.com/download/${MY_P}.tar.bz2
	mirror://gentoo/${PN}-2.1pre33-utf8.diff.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 directfb fbcon gpm jpeg livecd png sdl ssl svga tiff unicode X zlib"

# Note: if X or fbcon usegflag are enabled, links will be built in graphic
# mode. libpng is required to compile links in graphic mode
# (not required in text mode), so let's add libpng for X? and fbcon?

# We've also made USE=livecd compile in graphics mode.  This closes bug #75685.

RDEPEND="ssl? ( >=dev-libs/openssl-0.9.6c )
	gpm? ( sys-libs/gpm )
	png? ( >=media-libs/libpng-1.2.1 )
	jpeg? ( >=media-libs/jpeg-6b )
	fbcon? ( >=media-libs/libpng-1.2.1
		>=media-libs/jpeg-6b
		sys-libs/gpm )
	tiff? ( >=media-libs/tiff-3.5.7 )
	svga? ( >=media-libs/svgalib-1.4.3
		>=media-libs/libpng-1.2.1 )
	X? ( x11-libs/libXext
		>=media-libs/libpng-1.2.1 )
	directfb? ( dev-libs/DirectFB )
	sdl? ( >=media-libs/libsdl-1.2.0 )
	sys-libs/ncurses
	livecd? ( >=media-libs/libpng-1.2.1
		>=media-libs/jpeg-6b
		sys-libs/gpm )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack (){
	unpack ${A}; cd "${S}"

	epatch "${FILESDIR}"/configure-LANG.patch #131440

	if use unicode ; then
		epatch "${WORKDIR}/${PN}-2.1pre33-utf8.diff"
		cd "${S}/intl" && ./gen-intl && cd .. || die "gen-intl failed"
		cd "${S}/intl" && ./synclang && cd .. || die "synclang failed"
	fi
	# Upstream configure produced by broken autoconf-2.13. See #131440 and
	# #103483#c23
	eautoconf || die "autoconf failed"
}

src_compile (){
	local myconf

	if use X || use fbcon || use directfb || use svga || use livecd; then
		myconf="${myconf} --enable-graphics"
	fi

	# Note: --enable-static breaks.

	# Note: ./configure only support 'gpm' features auto-detection, so
	# we use the autoconf trick
	( use gpm || use fbcon || use livecd ) || export ac_cv_lib_gpm_Gpm_Open="no"

	export LANG=C

	if use fbcon || use livecd; then
		myconf="${myconf} --with-fb"
	else
		myconf="${myconf} --without-fb"
	fi

	# force --with-libjpeg if livecd flag is set
	if use livecd; then
		myconf="${myconf} --with-libjpeg"
	fi

	# hack to allow cross-compilation
	export CC="$(tc-getCC)"

	econf \
		$(use_with X x) \
		$(use_with png libpng) \
		$(use_with jpeg libjpeg) \
		$(use_with tiff libtiff) \
		$(use_with svga svgalib) \
		$(use_with directfb) \
		$(use_with ssl) \
		$(use_with sdl) \
		$(use_with zlib) \
		$(use_with bzip2) \
		${myconf} || die "configure failed"
	emake || die "make failed"
}

src_install() {
	einstall || die

	# Only install links icon if X driver was compiled in ...
	use X && doicon graphics/links.xpm

	dodoc AUTHORS BUGS ChangeLog NEWS README SITES TODO
	dohtml doc/links_cal/*

	# Install a compatibility symlink links2:
	dosym links /usr/bin/links2
}

pkg_postinst() {
	if use svga ; then
		elog "You had the svga USE flag enabled, but for security reasons"
		elog "the links2 binary is NOT setuid by default. In order to"
		elog "enable links2 to work in SVGA, please change the permissions"
		elog "of /usr/bin/links2 to enable suid."
	fi
}
