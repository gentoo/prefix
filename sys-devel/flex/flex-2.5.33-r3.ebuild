# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.33-r3.ebuild,v 1.11 2007/12/13 04:11:26 vapier Exp $

inherit eutils flag-o-matic

#DEB_VER=36
DESCRIPTION="GNU lexical analyser generator"
HOMEPAGE="http://flex.sourceforge.net/"
SRC_URI="mirror://sourceforge/flex/${P}.tar.bz2"
#	mirror://debian/pool/main/f/flex/${PN}_${PV}-${DEB_VER}.diff.gz"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -n ${DEB_VER} ]] && epatch "${WORKDIR}"/${PN}_${PV}-${DEB_VER}.diff
	epatch "${FILESDIR}"/${PN}-2.5.31-include.patch
	epatch "${FILESDIR}"/${P}-isatty.patch #119598
	epatch "${FILESDIR}"/${P}-pic.patch
	epatch "${FILESDIR}"/${P}-setlocale.patch #186092
	touch doc/flex.1 #187505
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
