# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/texmfind/texmfind-0.1.ebuild,v 1.6 2008/07/06 03:14:58 wormo Exp $

inherit eutils prefix

DESCRIPTION="Finds which ebuild provide a texmf file matching a grep regexp."
HOMEPAGE="http://home.gna.org/texmfind"
SRC_URI="http://download.gna.org/texmfind/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="kernel_Darwin? ( app-misc/getopt )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"

	epatch "${FILESDIR}"/${P}-getopt.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify texmfind
}

src_install() {
	dobin texmfind 						   || die "dobin failed"
	doman texmfind.1 					   || die "doman failed"
	insinto /usr/share/texmf-site/texmfind || die "insinto failed"
	doins texmf_files 					   || die "doins failed"
}
