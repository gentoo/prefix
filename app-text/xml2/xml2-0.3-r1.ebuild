# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xml2/xml2-0.3-r1.ebuild,v 1.4 2008/01/19 15:12:46 grobian Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Converts XML to line-oriented file format"

HOMEPAGE="http://dan.egnor.name/xml2/"

SRC_URI="http://download.gale.org/${P}.tar.gz"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~x86-linux ~ppc-macos"

IUSE=""

DEPEND="dev-libs/libxml2"

src_unpack() {
	unpack "${A}"
	cd "${S}"

	epatch ${FILESDIR}/${P}-libxml2.patch
	sed -i -e "s:CFLAGS=-g -Wall:CFLAGS=${CFLAGS}:" makefile || \
		die "Sed expression failed"
}

src_compile() {
	emake || die "make failed"
}

src_install() {
	dobin 2csv 2xml csv2 xml2
	# HTML support symlinks, upstream considers it be necessary
	dosym /usr/bin/2xml /usr/bin/2html
	dosym /usr/bin/xml2 /usr/bin/html2
}
