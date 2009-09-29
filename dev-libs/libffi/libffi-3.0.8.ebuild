# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libffi/libffi-3.0.8.ebuild,v 1.17 2009/09/23 19:15:35 aballier Exp $

EAPI=2
inherit eutils autotools

DESCRIPTION="a portable, high level programming interface to various calling conventions."
HOMEPAGE="http://sourceware.org/libffi"
SRC_URI="ftp://sourceware.org/pub/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~hppa-hpux ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="debug static-libs test"

RDEPEND=""
DEPEND="!<dev-libs/g-wrap-1.9.11
	test? ( dev-util/dejagnu )"

src_prepare() {
	epatch "${FILESDIR}/${P}-fbsd.patch"
	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable debug)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc ChangeLog* README TODO
}

pkg_postinst() {
	ewarn "Please unset USE flag libffi in sys-devel/gcc. There is no"
	ewarn "file collision but your package might link to wrong library."
	ebeep
}
