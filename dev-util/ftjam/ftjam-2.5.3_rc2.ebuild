# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/ftjam/ftjam-2.5.3_rc2.ebuild,v 1.7 2007/12/22 18:30:15 nixnut Exp $

EAPI="prefix"

inherit eutils versionator

MY_PV=$(delete_version_separator _)

DESCRIPTION="Jam is a powerful alternative to make.  FTJam is a 100% compatible enhanced Jam implementation."
HOMEPAGE="http://freetype.sourceforge.net/jam/index.html"
SRC_URI="http://david.freetype.org/jam/ftjam-${MY_PV}.tar.bz2"

LICENSE="perforce GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="!dev-util/jam
	sys-devel/bison"
RDEPEND="!dev-util/jam"

S=${WORKDIR}/${PN}-${MY_PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/ftjam-2.5.3-nostrip.patch
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README README.ORG CHANGES INSTALL RELNOTES
	dohtml Jam.html Jambase.html Jamfile.html
}
