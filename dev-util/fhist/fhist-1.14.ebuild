# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/fhist/fhist-1.14.ebuild,v 1.5 2008/05/12 22:23:54 pva Exp $

DESCRIPTION="File history and comparison tools"
HOMEPAGE="http://www.canb.auug.org.au/~millerp/fhist.html"
SRC_URI="http://www.canb.auug.org.au/~millerp/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="sys-devel/gettext
		sys-apps/groff"
DEPEND="${RDEPEND}
		sys-devel/bison"

src_compile() {
	econf || die "econf failed"
	emake -j1 || die "emake failed"
}

src_test() {
	make sure || die "src_test failed"
}

src_install () {
	make RPM_BUILD_ROOT="${D}" NLSDIR="${ED}/usr/share/locale" \
		install || die "make install failed"

	dodoc lib/en/*.txt
	dodoc lib/en/*.ps

	# remove duplicate docs etc.
	rm -r "${ED}"/usr/share/fhist

	dodoc LICENSE MANIFEST README
}
