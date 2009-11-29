# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/quixote/quixote-2.6.ebuild,v 1.2 2009/11/26 10:06:21 djc Exp $

inherit distutils

MY_P=${P/q/Q}

DESCRIPTION="Python HTML templating framework for developing web applications."
HOMEPAGE="http://quixote.ca"
SRC_URI="http://quixote.ca/releases/${MY_P}.tar.gz"

LICENSE="CNRI-QUIXOTE-2.4"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=">=dev-lang/python-2.3"

S="${WORKDIR}"/${MY_P}

src_install() {
	DOCS="ACKS.txt CHANGES.txt"
	distutils_src_install
	dodoc doc/*.txt
	dohtml doc/*.html
}
