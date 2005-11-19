# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.31.ebuild,v 1.15 2005/09/15 05:33:07 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DEB_VER=34
DESCRIPTION="GNU lexical analyser generator"
HOMEPAGE="http://lex.sourceforge.net/"
SRC_URI="mirror://sourceforge/lex/${P}.tar.bz2
	mirror://debian/pool/main/f/flex/${PN}_${PV}-${DEB_VER}.diff.gz"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="build nls static"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${PN}_${PV}-${DEB_VER}.diff
	epatch "${FILESDIR}"/${P}-include.patch
}

src_compile() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die
	emake || die
}

src_install() {
	make install DESTDIR="${DEST}" || die "make install failed"

	if use build ; then
		rm -r "${D}"/usr/{include,lib,share}
	else
		dodoc AUTHORS ChangeLog NEWS ONEWS README* RoadMap THANKS TODO
	fi

	dosym flex /usr/bin/lex
}
