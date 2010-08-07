# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/fastjar/fastjar-0.98.ebuild,v 1.5 2010/05/26 18:45:01 pacho Exp $

inherit autotools

DESCRIPTION="A jar program written in C"
HOMEPAGE="https://savannah.nongnu.org/projects/fastjar"
SRC_URI="http://download.savannah.nongnu.org/releases/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"

IUSE=""

# bug #188542
RDEPEND="!<=dev-java/kaffe-1.1.7-r5"
DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	AT_M4DIR="m4" eautoreconf # need new libtool for interix
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO || die
}
