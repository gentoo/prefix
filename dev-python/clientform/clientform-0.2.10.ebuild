# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/clientform/clientform-0.2.10.ebuild,v 1.1 2008/12/07 10:51:32 patrick Exp $

inherit distutils

MY_P="ClientForm-${PV}"
DESCRIPTION="Parse, fill out, and return HTML forms on the client side"
HOMEPAGE="http://wwwsearch.sourceforge.net/ClientForm/"
SRC_URI="http://wwwsearch.sourceforge.net/ClientForm/src/${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE="examples"

S="${WORKDIR}/${MY_P}"
DOCS="*.txt"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# use distutils instead of setuptools
	sed -i \
		-e 's/not hasattr(sys, "version_info")/1/' \
		setup.py || die "sed failed"
}

src_test() {
	"${python}" test.py || die "test.py failed"
}

src_install() {
	# remove to prevent distutils_src_install from installing it
	dohtml *.html
	rm README.html*

	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
