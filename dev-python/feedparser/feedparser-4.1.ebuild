# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/feedparser/feedparser-4.1.ebuild,v 1.13 2009/09/10 03:12:45 arfrever Exp $

EAPI="2"

inherit distutils

DESCRIPTION="Parse RSS and Atom feeds in Python"
HOMEPAGE="http://www.feedparser.org/"
SRC_URI="mirror://sourceforge/feedparser/${P}.zip"

LICENSE="PYTHON"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""

S=${WORKDIR}
DOCS="LICENSE"

src_install() {
	distutils_src_install

	insinto /usr/share/doc/${PF}
	doins -r docs
}
