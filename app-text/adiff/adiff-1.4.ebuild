# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/adiff/adiff-1.4.ebuild,v 1.3 2009/05/19 21:01:56 ranger Exp $

DESCRIPTION="wordwise diff"
HOMEPAGE="http://agriffis.n01se.net/adiff/"
SRC_URI="${HOMEPAGE}/${P}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="dev-lang/perl
	!app-arch/atool"
RDEPEND="${DEPEND}
	sys-apps/diffutils"

S=${WORKDIR}

src_unpack() {
	cd "${S}"
	cp "${DISTDIR}"/${P} .
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl -w' ${P}
}

src_compile() {
	pod2man --release=${PV} --center="${HOMEPAGE}" \
		--date="2007-12-11" "${DISTDIR}"/${P} ${PN}.1 || die
}

src_install() {
	newbin "${S}"/${P} ${PN}
	doman ${PN}.1
}
