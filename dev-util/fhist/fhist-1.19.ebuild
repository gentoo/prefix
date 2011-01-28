# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/fhist/fhist-1.19.ebuild,v 1.1 2011/01/06 21:06:29 jlec Exp $

EAPI="3"

inherit eutils

DESCRIPTION="File history and comparison tools"
HOMEPAGE="http://fhist.sourceforge.net/fhist.html"
SRC_URI="http://fhist.sourceforge.net/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-3"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
IUSE="test"

RDEPEND="
	dev-libs/libexplain
	sys-devel/gettext
	sys-apps/groff"
DEPEND="${RDEPEND}
	sys-devel/bison
	test? ( app-arch/sharutils )"

src_prepare() {
	epatch "${FILESDIR}"/${PV}-ldflags.patch
}

src_install () {
	emake -j1 DESTDIR="${D}" \
		install || die "make install failed"

	dodoc README || die
}
