# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/fig2sxd/fig2sxd-0.20.ebuild,v 1.1 2009/09/01 02:31:58 markusle Exp $

EAPI="2"

inherit eutils toolchain-funcs

DESCRIPTION="A utility to convert files in xfig format to OpenOffice.org Draw format"
LICENSE="GPL-2"

HOMEPAGE="http://sourceforge.net/projects/fig2sxd"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}.orig.tar.gz
	 mirror://sourceforge/${PN}/${PN}_${PV}-1.diff.gz"

SLOT="0"

KEYWORDS="~x86-linux ~ppc-macos"

IUSE=""

src_prepare() {
	epatch "${WORKDIR}"/${PN}_${PV}-1.diff
	epatch "${FILESDIR}"/${P}-ldflags.patch
	epatch "${FILESDIR}"/${P}-phony-check.patch
}

src_compile() {
	emake CXXFLAGS="${CXXFLAGS}" CXX="$(tc-getCXX)" \
		|| die "emake failed"
}

src_install() {
	dobin ${PN} || die "Failed to install binary."
	doman ${PN}.1 || die "Failed to install man page."
	dodoc changelog || die "Failed ton install docs."
}
