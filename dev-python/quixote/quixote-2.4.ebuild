# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/quixote/quixote-2.4.ebuild,v 1.5 2008/01/17 18:38:14 grobian Exp $

EAPI="prefix"

inherit distutils

MY_P=${P/q/Q}
DESCRIPTION="Python HTML templating framework for developing web applications."
HOMEPAGE="http://www.mems-exchange.org/software/quixote/"
SRC_URI="http://www.mems-exchange.org/software/files/${PN}/${MY_P}.tar.gz"
LICENSE="CNRI-QUIXOTE-2.4"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND=">=dev-lang/python-2.3"

S=${WORKDIR}/${MY_P}

src_install() {
	DOCS="ACKS CHANGES"
	distutils_src_install
	dodoc doc/*.txt
	dohtml doc/*.html
}
