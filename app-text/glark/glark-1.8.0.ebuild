# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/glark/glark-1.8.0.ebuild,v 1.2 2008/01/17 20:36:45 grobian Exp $

EAPI="prefix"

inherit bash-completion

DESCRIPTION="File searcher similar to grep but with fancy output"
HOMEPAGE="http://www.incava.org/projects/glark/"
SRC_URI="http://www.incava.org/pub/${PN}/${P}.tar.gz"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"
LICENSE="LGPL-2.1"
IUSE=""

# perl dep is for pod2man
DEPEND="virtual/ruby
	dev-lang/perl"
RDEPEND="virtual/ruby"

src_compile() {
	emake
	# force the manpage to be rebuilt
	rm ${PN}.1
	make ${PN}.1
}

src_install () {
	emake DESTDIR="${ED}" install
	dobashcompletion "${FILESDIR}"/1.8.0/glark-completion ${PN}
}
