# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/qgit/qgit-2.2.ebuild,v 1.3 2009/01/21 22:22:19 maekke Exp $

EAPI=1

inherit qt4

MY_PV=${PV//_/}
MY_P=${PN}-${MY_PV}

DESCRIPTION="GUI interface for git/cogito SCM"
HOMEPAGE="http://digilander.libero.it/mcostalba/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="|| ( x11-libs/qt-gui:4 =x11-libs/qt-4.3*:4 )"
RDEPEND="${DEPEND}
	>=dev-util/git-1.5.3"

S="${WORKDIR}/${PN}"

src_compile() {
	eqmake4 || die "eqmake failed"
	emake || die "emake failed"
}

src_install() {
	newbin bin/qgit qgit4
	dodoc README
}

pkg_postinst() {
	elog "This is installed as qgit4 now so you can still use 1.5 series (Qt3-based)"
}
