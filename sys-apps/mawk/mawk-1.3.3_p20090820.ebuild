# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/mawk/mawk-1.3.3_p20090820.ebuild,v 1.1 2009/08/23 09:53:48 vapier Exp $

EAPI="2"

inherit toolchain-funcs

MY_P=${P/_p/-}
DESCRIPTION="an (often faster than gawk) awk-interpreter"
HOMEPAGE="http://freshmeat.net/projects/mawk/"
SRC_URI="ftp://invisible-island.net/mawk/${MY_P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i 's:mkdirs.sh:./mkdirs.sh:' Makefile.in || die
}

src_configure() {
	tc-export CC # stupid configure script
	econf || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ACKNOWLEDGMENT CHANGES INSTALL README
}
