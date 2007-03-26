# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-back-xlib/gnustep-back-xlib-0.10.3.ebuild,v 1.3 2006/10/25 04:48:22 tsunam Exp $

EAPI="prefix"

inherit gnustep

S=${WORKDIR}/gnustep-back-${PV}

DESCRIPTION="Default X11 back-end component for the GNUstep GUI Library"

HOMEPAGE="http://www.gnustep.org"
SRC_URI="ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-back-${PV}.tar.gz"
KEYWORDS="~amd64 ~x86"
SLOT="0"
LICENSE="LGPL-2.1"

PROVIDE="virtual/gnustep-back"

IUSE="opengl xim"
DEPEND="${GNUSTEP_CORE_DEPEND}
	>=gnustep-base/gnustep-make-1.10
	>=gnustep-base/gnustep-base-1.10
	~gnustep-base/gnustep-gui-0.11.0
	opengl? ( virtual/opengl virtual/glu )
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXt
	x11-libs/libXft
	x11-libs/libXrender
	dev-libs/expat
	media-libs/fontconfig
	>=media-libs/freetype-2.1.9
	!virtual/gnustep-back"
RDEPEND="${DEPEND}
	${DEBUG_DEPEND}
	${DOC_RDEPEND}"

egnustep_install_domain "System"

src_unpack() {
	unpack ${A}
	cd ${S}
	EPATCH_OPTS="-d ${S}" epatch "${FILESDIR}/font-make-fix.patch-0.10.3"
}

src_compile() {
	egnustep_env

	use opengl && myconf="--enable-glx"
	myconf="$myconf `use_enable xim`"
	myconf="$myconf --enable-server=x11"
	myconf="$myconf --enable-graphics=xlib --with-name=xlib"
	econf $myconf || die "configure failed"

	egnustep_make
}

