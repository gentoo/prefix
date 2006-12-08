# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cabextract/cabextract-1.2.ebuild,v 1.1 2006/11/14 13:52:44 peper Exp $

EAPI="prefix"

DESCRIPTION="Extracts files from Microsoft .cab files"
HOMEPAGE="http://www.kyz.uklinux.net/cabextract.php"
SRC_URI="http://www.kyz.uklinux.net/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"

	dodoc AUTHORS ChangeLog INSTALL NEWS README TODO doc/magic
	dohtml doc/wince_cab_format.html
}
