# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/fig2sxd/fig2sxd-0.13.ebuild,v 1.1 2006/01/29 19:35:32 cryos Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="A utility to convert files in xfig format to OpenOffice.org Draw format"
LICENSE="GPL-2"

HOMEPAGE="http://sourceforge.net/projects/fig2sxd"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}.orig.tar.gz
		 mirror://sourceforge/${PN}/${PN}_${PV}-1.diff.gz"

SLOT="0"

KEYWORDS="~x86-linux ~ppc-macos"

IUSE=""

# Our workdir is somewhat different due
# to the tarball name
S="${WORKDIR}/${P}.orig"

src_unpack() {
	unpack ${A}
	epatch "${WORKDIR}"/${PN}_${PV}-1.diff
}

src_compile() {
	emake CXXF="${CXXFLAGS}" CXX="$(tc-getCXX)" || die "emake failed"
}

src_install() {
	dobin ${PN} || die
	doman ${PN}.1 || die
	dodoc debian/changelog || die
}
