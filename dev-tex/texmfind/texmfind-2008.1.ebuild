# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/texmfind/texmfind-2008.1.ebuild,v 1.4 2009/09/20 15:50:31 aballier Exp $

inherit eutils prefix

DESCRIPTION="Finds which ebuild provide a texmf file matching a grep regexp."
HOMEPAGE="https://launchpad.net/texmfind/
	http://home.gna.org/texmfind"
SRC_URI="http://launchpad.net/texmfind/2008/${PV}/+download/texmfind-${PV}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="kernel_Darwin? ( app-misc/getopt )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${WORKDIR}"

	epatch "${FILESDIR}"/${PN}-0.1-getopt.patch
	epatch "${FILESDIR}"/${PN}-0.1-prefix.patch
	eprefixify texmfind
}

src_install() {
	emake DESTDIR="${D}" install || die
}
