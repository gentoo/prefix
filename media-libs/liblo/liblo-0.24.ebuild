# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/liblo/liblo-0.24.ebuild,v 1.5 2008/04/18 22:10:48 maekke Exp $

DESCRIPTION="Lightweight OSC (Open Sound Control) implementation"
HOMEPAGE="http://plugin.org.uk/liblo"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="doc ipv6"

RDEPEND=""
DEPEND="doc? ( app-doc/doxygen )"

src_compile() {
	use doc || export ac_cv_prog_HAVE_DOXYGEN="false"
	econf --disable-dependency-tracking $(use_enable ipv6)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}

# tests fail when executed by ebuild/emerge,
# but succeed when executed manually, even from
# sandboxshell.
# if anybody knows why, please let me know..
src_test() {
	make test || die "make test failed"
}
