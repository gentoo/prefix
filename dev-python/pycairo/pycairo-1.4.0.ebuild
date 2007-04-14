# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pycairo/pycairo-1.4.0.ebuild,v 1.1 2007/03/14 23:15:56 marienz Exp $

EAPI="prefix"

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="examples"

RDEPEND=">=dev-lang/python-2.3
	>=x11-libs/cairo-1.4.0"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_install() {
	make DESTDIR="${D}" install || die "install failed"

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi

	dodoc AUTHORS NOTES README NEWS ChangeLog
}
