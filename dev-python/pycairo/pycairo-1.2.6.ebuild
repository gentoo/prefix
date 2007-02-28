# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-python/pycairo/pycairo-1.2.6.ebuild,v 1.3 2007/01/28 17:50:33 uberlord Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils autotools

DESCRIPTION="Python wrapper for cairo vector graphics library"
HOMEPAGE="http://cairographics.org/pycairo"
SRC_URI="http://cairographics.org/releases/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="examples numeric"

RDEPEND=">=dev-lang/python-2.3
	>=x11-libs/cairo-1.2.6
	numeric? ( dev-python/numeric )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-no-automagic-deps.patch

	eautoreconf
}

src_compile() {
	econf \
		$(use_with numeric) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"

	if use examples ; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		rm "${ED}"/usr/share/doc/${PF}/examples/Makefile*
	fi

	dodoc AUTHORS NOTES README NEWS ChangeLog
}
