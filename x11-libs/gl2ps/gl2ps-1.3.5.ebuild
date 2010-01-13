# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/gl2ps/gl2ps-1.3.5.ebuild,v 1.2 2010/01/03 19:53:00 ssuominen Exp $

EAPI=2
inherit cmake-utils

DESCRIPTION="OpenGL to PostScript printing library"
HOMEPAGE="http://www.geuz.org/gl2ps/"
SRC_URI="http://geuz.org/${PN}/src/${P}.tgz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="png zlib"

DEPEND="virtual/glut
	png? ( media-libs/libpng )
	zlib? ( sys-libs/zlib )"

S=${WORKDIR}/${P}-source

PATCHES=( "${FILESDIR}/${P}-CMakeLists.patch" )

src_configure() {
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use_has png PNG)
		$(cmake-utils_use_has zlib ZLIB)"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	prepalldocs
}
