# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/fhist/fhist-1.16.ebuild,v 1.4 2009/12/04 21:57:41 flameeyes Exp $

DESCRIPTION="File history and comparison tools"
HOMEPAGE="http://fhist.sourceforge.net/fhist.html"
SRC_URI="http://fhist.sourceforge.net/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
IUSE="test"

RDEPEND="sys-devel/gettext
		sys-apps/groff"
DEPEND="${RDEPEND}
		test? ( app-arch/sharutils )
		sys-devel/bison"

src_compile() {
	econf || die "econf failed"
	# bug #295744
	emake -j1 || die "emake failed"
}

src_test() {
	emake -j1 sure || die "src_test failed"
}

src_install () {
	emake -j1 RPM_BUILD_ROOT="${D}" NLSDIR="${ED}/usr/share/locale" \
		install || die "make install failed"

	dodoc lib/en/*.txt
	dodoc lib/en/*.ps

	# remove duplicate docs etc.
	rm -r "${ED}"/usr/share/fhist

	dodoc MANIFEST README
}
