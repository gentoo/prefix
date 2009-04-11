# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-calculators/wcalc/wcalc-2.2.1.ebuild,v 1.5 2008/01/31 07:24:24 opfer Exp $

DESCRIPTION="A flexible command-line scientific calculator"
HOMEPAGE="http://w-calc.sourceforge.net"
SRC_URI="mirror://sourceforge/w-calc/Wcalc-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="readline"

DEPEND="readline? ( >=sys-libs/readline-4.3-r4 )
	>=dev-libs/mpfr-2.1
	dev-libs/gmp"

S="${WORKDIR}"/Wcalc-${PV}

src_compile() {
	econf $(use_with readline) || die "Configuration failed."
	emake || die "Compilation failed."
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README

	# Wcalc icons
	insinto /usr/share/pixmaps
	newins w.png wcalc.png
	newins Wred.png wcalc-red.png
}
