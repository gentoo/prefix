# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-calculators/wcalc/wcalc-2.3.ebuild,v 1.1 2008/01/29 12:28:04 bicatali Exp $

EAPI="prefix"

inherit eutils

MYP="Wcalc-${PV}"
DESCRIPTION="A flexible command-line scientific calculator"
HOMEPAGE="http://w-calc.sourceforge.net"
SRC_URI="mirror://sourceforge/w-calc/${MYP}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="readline"

DEPEND="readline? ( sys-libs/readline )
	dev-libs/mpfr
	dev-libs/gmp"

S="${WORKDIR}"/${MYP}

src_compile() {
	econf $(use_with readline) || die "econf failed."
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README || die

	# Wcalc icons
	newicon w.png wcalc.png || die
	newicon Wred.png wcalc-red.png || die
}
