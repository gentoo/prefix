# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/liblo/liblo-0.23.ebuild,v 1.6 2006/06/11 19:10:40 corsair Exp $

EAPI="prefix"

IUSE="doc"

DESCRIPTION="Lightweight OSC (Open Sound Control) implementation"
HOMEPAGE="http://plugin.org.uk/liblo/"
SRC_URI="http://www.ecs.soton.ac.uk/~njh/liblo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos"

DEPEND="dev-util/pkgconfig
		doc? ( app-doc/doxygen )"

src_compile() {
	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	einstall || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}

# tests fail when executed by ebuild/emerge,
# but succeed when executed manually, even from
# sandboxshell.
# if anybody knows why, please let me know..
src_test() {
	make test || die "make test failed"
}
