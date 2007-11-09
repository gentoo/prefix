# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/lha/lha-114i-r7.ebuild,v 1.1 2007/07/22 14:21:32 drac Exp $

EAPI="prefix"

inherit eutils autotools

MY_P="${PN}-1.14i-ac20050924p1"

DESCRIPTION="Utility for creating and opening lzh archives"
HOMEPAGE="http://lha.sourceforge.jp"
SRC_URI="mirror://sourceforge.jp/${PN}/22231/${MY_P}.tar.gz"

LICENSE="lha"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}"/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-file-list-from-stdin.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" \
		mandir="${EPREFIX}"/usr/share/man/ja \
		install || die "emake failed."
	dodoc ChangeLog Hacking_of_LHa
}
