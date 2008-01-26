# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/epm/epm-1.33.ebuild,v 1.3 2007/08/16 10:08:01 uberlord Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="rpm workalike for Gentoo Linux"
HOMEPAGE="http://www.gentoo.org/~agriffis/epm/"
SRC_URI="http://www.gentoo.org/~agriffis/epm/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=dev-lang/perl-5"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify epm
}

src_compile() {
	pod2man epm > epm.1 || die "pod2man failed"
}

src_install() {
	dobin epm || die
	doman epm.1
}
