# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/buddy/buddy-2.4.ebuild,v 1.2 2008/06/03 10:37:38 markusle Exp $

EAPI="prefix"

DESCRIPTION="BuDDY - A Binary Decision Diagram Package"
HOMEPAGE="http://sourceforge.net/projects/buddy"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"

IUSE=""
DEPEND="virtual/libc"

src_install() {
	make install DESTDIR="${D}" || die "make install failed"

	dodoc ChangeLog NEWS AUTHORS README doc/*.txt || \
		die "failed to install docs"

	insinto /usr/share/doc/${P}/ps
	doins doc/*.ps || die "failed to install postscripts files"

	insinto /usr/share/${PN}/examples
	cd examples
	for example in *; do
		tar -czf ${example}.tar.gz ${example}
		doins ${example}.tar.gz
	done
}
