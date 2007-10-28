# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-gui/gnustep-gui-0.12.0.ebuild,v 1.8 2007/10/27 15:48:36 nixnut Exp $

EAPI="prefix"

inherit gnustep-base multilib

DESCRIPTION="Library of GUI classes written in Obj-C"
HOMEPAGE="http://www.gnustep.org/"
SRC_URI="ftp://ftp.gnustep.org/pub/gnustep/core/${P}.tar.gz"

KEYWORDS="~amd64 ~x86 ~x86-solaris"
SLOT="0"
LICENSE="LGPL-2.1"

IUSE="jpeg gif png cups"

DEPEND="${GNUSTEP_CORE_DEPEND}
	>=gnustep-base/gnustep-base-1.14.0
	x11-libs/libXt
	>=media-libs/tiff-3
	jpeg? ( >=media-libs/jpeg-6b )
	gif? ( >=media-libs/giflib-4.1 )
	png? ( >=media-libs/libpng-1.2 )
	cups? ( >=net-print/cups-1.1 )
	media-libs/audiofile
	app-text/aspell"
RDEPEND="${DEPEND}"

src_compile() {
	egnustep_env

	myconf="--with-tiff-include=${EPREFIX}/usr/include --with-tiff-library=${EPREFIX}/usr/$(get_libdir)"
	use gif && myconf="$myconf --disable-ungif --enable-libgif"
	myconf="$myconf `use_enable jpeg`"
	myconf="$myconf `use_enable png`"
	myconf="$myconf `use_enable cups`"
	# gsnd is disabled until portaudio-19 is unmasked in portage
	myconf="$myconf --disable-gsnd"

	econf $myconf || die "configure failed"

	egnustep_make || die
}
