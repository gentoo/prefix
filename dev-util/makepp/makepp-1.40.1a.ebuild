# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/makepp/makepp-1.40.1a.ebuild,v 1.1 2005/09/22 06:27:15 vapier Exp $

inherit eutils

DESCRIPTION="GNU make replacement"
HOMEPAGE="http://makepp.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=dev-lang/perl-5.6.0"

S=${WORKDIR}/${P%.*}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-install.patch
	# remove ones which cause sandbox violations
	rm makepp_tests/wildcard_repositories.test
}

src_compile() {
	# not an autoconf configure script
	./configure \
		--prefix="${EPREFIX}"/usr \
		--bindir="${EPREFIX}"/usr/bin \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--mandir="${EPREFIX}"/usr/share/man \
		--datadir="${EPREFIX}"/usr/share/makepp \
		|| die "configure failed"
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc ChangeLog README
}
