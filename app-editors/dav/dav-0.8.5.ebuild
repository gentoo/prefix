# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/dav/dav-0.8.5.ebuild,v 1.9 2007/03/12 18:29:52 armin76 Exp $

EAPI="prefix"

DESCRIPTION="A minimal console text editor"
HOMEPAGE="http://dav-text.sourceforge.net/"

# The maintainer does not keep sourceforge's mirrors up-to-date,
# so we point to the website's store of files.
SRC_URI="http://dav-text.sourceforge.net/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND="sys-libs/ncurses"

src_compile() {
	emake CFLAGS="${CFLAGS}" LDFLAGS="-lncurses ${CFLAGS}" || die
}

src_install() {
	# no configure, is no prefix known
	emake DESTDIR="${D}${EPREFIX}" install || die
}
