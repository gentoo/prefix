# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.34.ebuild,v 1.1 2007/12/13 04:44:08 vapier Exp $

EAPI="prefix"

inherit eutils flag-o-matic

#DEB_VER=36
DESCRIPTION="GNU lexical analyser generator"
HOMEPAGE="http://flex.sourceforge.net/"
SRC_URI="mirror://sourceforge/flex/${P}.tar.bz2"
#	mirror://debian/pool/main/f/flex/${PN}_${PV}-${DEB_VER}.diff.gz"

LICENSE="FLEX"
SLOT="0"
# Three regressions (according to test suite):
# http://sourceforge.net/tracker/index.php?func=detail&aid=1849812&group_id=97492&atid=618177
# http://sourceforge.net/tracker/index.php?func=detail&aid=1849809&group_id=97492&atid=618177
# http://sourceforge.net/tracker/index.php?func=detail&aid=1849805&group_id=97492&atid=618177
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -n ${DEB_VER} ]] && epatch "${WORKDIR}"/${PN}_${PV}-${DEB_VER}.diff
	epatch "${FILESDIR}"/${P}-isatty.patch #119598
	epatch "${FILESDIR}"/${PN}-2.5.33-pic.patch
}

src_compile() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS ONEWS README* THANKS TODO
	dosym flex /usr/bin/lex
}
