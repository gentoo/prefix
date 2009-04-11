# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/o3read/o3read-0.0.4.ebuild,v 1.8 2008/12/30 21:36:23 angelos Exp $

inherit toolchain-funcs

DESCRIPTION="Converts OpenOffice formats to text or HTML."
HOMEPAGE="http://siag.nu/o3read/"
SRC_URI="http://siag.nu/pub/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="test"

DEPEND="test? ( app-arch/unzip
	www-client/lynx )"

src_compile() {
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	dobin o3read o3totxt o3tohtml utf8tolatin1
	doman o3read.1 o3tohtml.1 o3totxt.1 utf8tolatin1.1
}

src_test() {
	emake lytest || die "make lytest failed"
}
