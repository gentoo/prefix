# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/sgrep/sgrep-1.92a.ebuild,v 1.6 2008/01/11 21:41:14 grobian Exp $

EAPI="prefix"

DESCRIPTION="Structured grep: tool for searching and indexing text, SGML,XML and HTML files and filtering text streams using structural criteria."
SRC_URI="ftp://ftp.cs.helsinki.fi/pub/Software/Local/Sgrep/${P}.tar.gz"
HOMEPAGE="http://www.cs.helsinki.fi/u/jjaakkol/sgrep.html"

LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="virtual/libc"
SLOT="0"

src_compile() {
	econf --datadir="${EPREFIX}"/etc || die "econf failed"
	emake || die "emake failed"

	sed -e "s:/usr/lib:/etc:g" sgrep.1 > sgrep.1.new
}

src_install() {
	dobin sgrep
	newman sgrep.1.new sgrep.1
	dodoc AUTHORS ChangeLog NEWS README sample.sgreprc
	insinto /etc
	newins sample.sgreprc sgreprc
}
