# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/rpm2targz/rpm2targz-9.0.0.5g.ebuild,v 1.1 2012/05/17 05:03:23 vapier Exp $

EAPI="4"

inherit toolchain-funcs eutils

DESCRIPTION="Convert a .rpm file to a .tar.gz archive"
HOMEPAGE="http://www.slackware.com/config/packages.php"
SRC_URI="mirror://gentoo/${P}.tar.xz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="app-arch/cpio"
DEPEND="app-arch/xz-utils"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i '/^prefix =/s:=.*:= '"${EPREFIX}"'/usr:' Makefile
}

src_compile() {
	emake CC="$(tc-getCC)"
}

src_install() {
	default
	dodoc *.README*
}
