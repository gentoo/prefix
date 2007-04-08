# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/corefonts/corefonts-1-r2.ebuild,v 1.13 2007/02/28 22:11:49 genstef Exp $

EAPI="prefix"

inherit font

DESCRIPTION="Microsoft's TrueType core fonts"
HOMEPAGE="http://corefonts.sourceforge.net/"
SRC_URI="mirror://sourceforge/corefonts/andale32.exe
	mirror://sourceforge/corefonts/arial32.exe
	mirror://sourceforge/corefonts/arialb32.exe
	mirror://sourceforge/corefonts/comic32.exe
	mirror://sourceforge/corefonts/courie32.exe
	mirror://sourceforge/corefonts/georgi32.exe
	mirror://sourceforge/corefonts/impact32.exe
	mirror://sourceforge/corefonts/times32.exe
	mirror://sourceforge/corefonts/trebuc32.exe
	mirror://sourceforge/corefonts/verdan32.exe
	mirror://sourceforge/corefonts/webdin32.exe"

LICENSE="MSttfEULA"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="X"

DEPEND="app-arch/cabextract"
RDEPEND=""

S=${WORKDIR}
FONT_S=${WORKDIR}
FONT_SUFFIX="ttf"

src_unpack() {
	for exe in ${A} ; do
		echo ">>> Unpacking ${exe} to ${WORKDIR}"
		cabextract --lowercase ${DISTDIR}/${exe} > /dev/null \
			|| die "failed to unpack ${exe}"
	done
}
