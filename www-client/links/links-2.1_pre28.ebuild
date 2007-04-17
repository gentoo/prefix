# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/links/links-2.1_pre28.ebuild,v 1.1 2007/04/14 19:11:04 vanquirius Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="links is a fast lightweight text and graphic web-browser"
HOMEPAGE="http://links.twibright.com/"
# To handle pre-version ...
MY_P="${P/_/}"
S="${WORKDIR}/${MY_P}"
SRC_URI="http://links.twibright.com/download/${MY_P}.tar.bz2
	mirror://gentoo/${PN}-2.1pre22-utf8.diff.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="directfb fbcon gpm javascript jpeg livecd png sdl ssl svga tiff unicode X"

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
	X? ( || ( x11-libs/libXext
		virtual/x11 )
		>=media-libs/libpng-1.2.1 )
	directfb? ( dev-libs/DirectFB )
	sdl? ( >=media-libs/libsdl-1.2.0 )
	sys-libs/zlib
	virtual/libc
	sys-libs/ncurses"

DEPEND="${RDEPEND}
	sys-devel/automake
	sys-devel/autoconf
	dev-util/pkgconfig
	javascript? ( >=sys-devel/flex-2.5.4a )"

src_unpack (){
	unpack ${A}; cd "${S}"

	epatch "${FILESDIR}"/configure-LANG.patch #131440

	if use unicode ; then
		epatch "${WORKDIR}/${PN}-2.1pre22-utf8.diff"
		cd "${S}/intl" && ./gen-intl && cd .. || die "gen-intl filed"
	fi
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
		$(use_enable javascript) \
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
