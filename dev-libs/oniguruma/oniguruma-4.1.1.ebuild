# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/oniguruma/oniguruma-4.1.1.ebuild,v 1.2 2007/06/24 20:31:21 angelos Exp $

EAPI="prefix"

MY_P="onig-${PV}"

DESCRIPTION="Regular expression library"
HOMEPAGE="http://www.geocities.jp/kosako3/oniguruma/"
SRC_URI="http://www.geocities.jp/kosako3/oniguruma/archive/${MY_P}.tar.gz"

LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="virtual/libc"

S=${WORKDIR}/${MY_P}

src_compile() {

	econf || die
	emake || die
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc HISTORY README doc/*
}
