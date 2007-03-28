# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/gsl/gsl-1.9.ebuild,v 1.4 2007/03/27 19:29:25 mcummings Exp $

EAPI="prefix"

inherit eutils flag-o-matic autotools

DESCRIPTION="The GNU Scientific Library"
HOMEPAGE="http://www.gnu.org/software/gsl/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/gsl-1.6-deps.diff
	eautoreconf
}

src_compile() {
	replace-cpu-flags k6 k6-2 k6-3 i586
	filter-flags -ffast-math

	econf --disable-libtool-lock || die "configure failed"
	emake || die 'emake failed.'
}

src_install() {
	make install DESTDIR=${D} || die 'install failed.'
	dodoc AUTHORS BUGS ChangeLog INSTALL NEWS README SUPPORT THANKS TODO
}
