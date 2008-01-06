# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/mbtpdfasm/mbtpdfasm-1.0.28.ebuild,v 1.1 2008/01/06 02:37:18 sbriesen Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

MY_P="mbtPdfAsm-${PV}"

DESCRIPTION="mbtPdfAsm can assemble/merge PDF files, extract information from PDF files, and update the metadata in PDF files."
HOMEPAGE="http://thierry.schmit.free.fr/dev/mbtPdfAsm/mbtPdfAsm2.html"
SRC_URI="http://thierry.schmit.free.fr/spip/IMG/gz/${MY_P}.tar.gz
	http://sbriesen.de/gentoo/distfiles/${P}-manual.pdf.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86"
IUSE=""

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-makefile.diff"
	epatch "${FILESDIR}/${P}-64bit.diff"
	epatch "${FILESDIR}/${P}-main.diff"
}

src_compile() {
	emake CC="$(tc-getCXX)" || die "emake failed"
}

src_install() {
	dobin mbtPdfAsm || die "install failed"
	insinto "/usr/share/doc/${PF}"
	newins ${P}-manual.pdf mbtPdfAsm.pdf
}
