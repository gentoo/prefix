# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit prefix

DESCRIPTION="Chained EPREFIX bootstrapping utility"
HOMEPAGE="http://dev.gentoo.org/~mduft"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-interix ~x86-linux"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	cp "${FILESDIR}"/prefix-chain-setup.in "${T}"/prefix-chain-setup
	eprefixify "${T}"/prefix-chain-setup
	dobin "${T}"/prefix-chain-setup
}

