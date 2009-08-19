# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/muParser/muParser-1.30.ebuild,v 1.2 2009/04/06 14:26:47 ranger Exp $

EAPI=2
inherit eutils

DESCRIPTION="Library for parsing mathematical expressions"
HOMEPAGE="http://muparser.sourceforge.net/"
SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"
MY_PN="${PN/P/p}"
MY_PV="v${PV/./}"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_PN}_${MY_PV}.tar.gz"

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}"

src_prepare() {
	# fix destdir and respect cxxflags
	# cant really use autotools cause muparser use bakefile
	# and too lasy to make an ebuild for it.
	epatch "${FILESDIR}"/${P}-build.patch
}

src_configure() {
	econf --disable-samples
}

src_test() {
	econf --enable-samples
	emake || die "emake failed"
	echo "LD_LIBRARY_PATH=${PWD}/lib samples/example1/example1 << EOF" > test.sh
	echo "quit" >> test.sh
	echo "EOF" >> test.sh
	sh ./test.sh || die "test failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc Changes.txt  Credits.txt || die "dodoc failed"
	if use doc; then
		insinto /usr/share/doc/${PF}
		doins -r docs/html || die
	fi
}
