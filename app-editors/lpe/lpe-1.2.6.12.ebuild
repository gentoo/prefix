# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/lpe/lpe-1.2.6.12.ebuild,v 1.1 2005/06/25 11:22:21 pyrania Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Lightweight Programmers Editor"
HOMEPAGE="http://cdsmith.twu.net/professional/opensource/lpe.html"
SRC_URI="mirror://debian/pool/main/l/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="x86"
IUSE="nls"

DEPEND="sys-libs/slang"

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${P}-slang.patch
}

src_compile() {
	econf `use_enable nls` || die
	emake || die
}

src_install() {
	make \
		prefix=${ED}/usr \
		datadir=${ED}/usr/share \
		mandir=${ED}/usr/share/man \
		infodir=${ED}/usr/share/info \
		docdir=${ED}/usr/share/doc/${PF} \
		exdir=${ED}/usr/share/doc/${PF}/examples \
		install || die
	prepalldocs
}
