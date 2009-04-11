# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/elph/elph-1.0.1.ebuild,v 1.3 2008/06/29 08:25:29 tove Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Estimated Locations of Pattern Hits - Motif finder program"
LICENSE="Artistic"
HOMEPAGE="http://cbcb.umd.edu/software/ELPH/"
SRC_URI="ftp://ftp.cbcb.umd.edu/pub/software/elph/ELPH-${PV}.tar.gz"

SLOT="0"
IUSE=""
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

S="${WORKDIR}/ELPH/sources"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "s/CC      := g++/CC      := $(tc-getCXX)/" \
		-e "s/-D_REENTRANT -g/-D_REENTRANT ${CXXFLAGS}/" \
		-e "s/LINKER    := g++/LINKER    := $(tc-getCXX)/" \
		Makefile || die "Failed to patch Makefile."
}

src_compile() {
	emake || die "Compilation failed."
}

src_install() {
	dobin elph || die "Failed to install program."
	cd "${WORKDIR}"/ELPH
	dodoc VERSION || die "Documentation installation failed."
	newdoc Readme.ELPH README || die "Readme installation failed."
}
