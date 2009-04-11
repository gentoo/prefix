# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-back-cairo/gnustep-back-cairo-0.14.0.ebuild,v 1.3 2008/09/21 15:32:10 nixnut Exp $

inherit gnustep-base

S=${WORKDIR}/gnustep-back-${PV}

DESCRIPTION="Cairo back-end component for the GNUstep GUI Library."

HOMEPAGE="http://www.gnustep.org"
SRC_URI="ftp://ftp.gnustep.org/pub/gnustep/core/gnustep-back-${PV}.tar.gz"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
SLOT="0"
LICENSE="LGPL-2.1"

IUSE="opengl xim glitz"
RDEPEND="${GNUSTEP_CORE_DEPEND}
	~gnustep-base/gnustep-gui-${PV}
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

	>=media-libs/freetype-2.1.9
	>=x11-libs/cairo-1.2.0
	!gnustep-base/gnustep-back-art
	!gnustep-base/gnustep-back-xlib"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	gnustep-base_pkg_setup

	if ! built_with_use x11-libs/cairo X; then
		eerror "x11-libs/cairo must be compiled with the X USE flag enabled"
		die "x11-libs/cairo rebuild needed"
	fi
}

src_compile() {
	egnustep_env

	use opengl && myconf="--enable-glx"
	myconf="$myconf $(use_enable xim)"
	myconf="$myconf --enable-server=x11"
	myconf="$myconf --enable-graphics=cairo"
	# Seems broken for now
	#myconf="$myconf $(use_enable glitz)"

	econf $myconf || die "configure failed"

	egnustep_make
}
