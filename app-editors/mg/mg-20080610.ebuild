# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mg/mg-20080610.ebuild,v 1.3 2008/10/24 06:31:04 ulm Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="Micro GNU/emacs, a port from the BSDs"
HOMEPAGE="http://www.xs4all.nl/~hanb/software/mg/"
SRC_URI="http://www.xs4all.nl/~hanb/software/mg/${P}.tar.gz"

LICENSE="public-domain BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

src_compile() {
	# econf won't work, as this script does not accept any parameters
	./configure || die "configure failed"
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install()  {
	einstall || die "einstall failed"
	dodoc README tutorial || die "dodoc failed"
}
