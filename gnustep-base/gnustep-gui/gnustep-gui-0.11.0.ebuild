# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-gui/gnustep-gui-0.11.0.ebuild,v 1.1 2006/12/05 20:22:42 grobian Exp $

EAPI="prefix"

inherit gnustep

DESCRIPTION="Library of GUI classes written in Obj-C"
HOMEPAGE="http://www.gnustep.org/"
SRC_URI="ftp://ftp.gnustep.org/pub/gnustep/core/${P}.tar.gz"

KEYWORDS=""
SLOT="0"
LICENSE="LGPL-2.1"

IUSE="${IUSE} jpeg gif png gsnd doc cups"

DEPEND="${GNUSTEP_CORE_DEPEND}
	>=gnustep-base/gnustep-make-1.12.0
	>=gnustep-base/gnustep-base-1.12.0
	|| (
		( x11-libs/libXt )
		virtual/x11
	)
	>=media-libs/tiff-3
	jpeg? ( >=media-libs/jpeg-6b )
	gif? ( >=media-libs/giflib-4.1 )
	png? ( >=media-libs/libpng-1.2 )
	gsnd? (
		>=media-libs/audiofile-0.2
	)
	cups? ( >=net-print/cups-1.1 )
	app-text/aspell"
# gsnd needs a recent portaudio that's not in the tree yet
#		=media-libs/portaudio-19*
RDEPEND="${DEPEND}
	${DEBUG_DEPEND}
	${DOC_RDEPEND}"

egnustep_install_domain "System"

src_unpack() {
	unpack ${A}

	cd ${S}

#	if use gsnd;
#	then
#		sed -i -e "s:#include <portaudio.h>:#include <portaudio-2/portaudio.h>:g" ${S}/Tools/gsnd/gsnd.m 
#		sed -i -e "s:-lportaudio:-lportaudio-2:g" ${S}/Tools/gsnd/GNUmakefile 
#		sed -i -e "s:^BUILD_GSND=.*$:BUILD_GSND=gsnd:g" ${S}/config.make.in 
#	fi
}

src_compile() {
	egnustep_env

	myconf="--with-tiff-include=${EPREFIX}/usr/include --with-tiff-library=${EPREFIX}/usr/lib"
	use gif && myconf="$myconf --disable-ungif --enable-libgif"
	myconf="$myconf `use_enable jpeg`"
	myconf="$myconf `use_enable png`"
	myconf="$myconf `use_enable cups`"

	if use gsnd;
	then
		myconf="$myconf `use_enable gsnd`"
		myconf="$myconf --with-audiofile-include=${EPREFIX}/usr/include --with-audiofile-lib=${EPREFIX}/usr/lib"
#		myconf="$myconf --with-include-flags=-I${EPREFIX}/usr/include/portaudio-2"
	fi

	econf $myconf || die "configure failed"

	egnustep_make || die

	if use doc;
	then
		cd ${S}/Documentation
		egnustep_make || die
	fi
}

src_install() {
	egnustep_env
	egnustep_install || die

	if use doc;
	then
		cd ${S}/Documentation
		egnustep_install || die
	fi

	use gsnd && newinitd ${FILESDIR}/gsnd.initd gsnd
}
