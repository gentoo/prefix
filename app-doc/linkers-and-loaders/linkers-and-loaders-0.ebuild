# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-doc/linkers-and-loaders/linkers-and-loaders-0.ebuild,v 1.4 2008/02/04 18:31:59 grobian Exp $

EAPI="prefix"

CH="|00e |01e |02e |03e |04e |05e |06e |07e |08e |09e |10e |11e |12e"
DESCRIPTION="the Linkers and Loaders book"
HOMEPAGE="http://www.iecc.com/linker/"
SRC_URI="doc? ( ${CH//e/.txt} ${CH//e/.rtf} ) ${CH//e/.html}"
SRC_URI="${SRC_URI//|/${HOMEPAGE}linker}"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc"
RESTRICT="mirror"

DEPEND=""

S="${WORKDIR}"

src_unpack() {
	local f
	for f in ${A} ; do
		cp "${DISTDIR}"/${f} . || die "copying ${f}"
	done
}

src_install() {
	dohtml *.html || die
	use doc && dodoc *.txt *.rtf
}
