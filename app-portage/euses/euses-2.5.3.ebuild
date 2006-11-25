# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/euses/euses-2.5.3.ebuild,v 1.1 2006/11/24 22:18:20 jer Exp $

EAPI="prefix"

inherit toolchain-funcs autotools

WANT_AUTOCONF="latest"

DESCRIPTION="look up USE flag descriptions fast"
HOMEPAGE="http://www.xs4all.nl/~rooversj/gentoo"
SRC_URI="http://www.xs4all.nl/~rooversj/gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="sys-devel/autoconf
	sys-devel/autoconf-wrapper"

S="${WORKDIR}"

src_unpack() {
	cd "${S}"
	unpack "${A}"
	eautoreconf
}

src_install() {
	dobin ${PN} || die
	doman ${PN}.1 || die
	dodoc ChangeLog || die
}
