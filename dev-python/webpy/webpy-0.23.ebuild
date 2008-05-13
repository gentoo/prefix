# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-python/webpy/webpy-0.23.ebuild,v 1.1 2008/02/11 10:54:51 wrobel Exp $

EAPI="prefix"

inherit distutils

MY_PN="web.py"

DESCRIPTION="A small and simple web framework for python"
HOMEPAGE="http://www.webpy.org"
SRC_URI="http://www.webpy.org/static/${MY_PN}-${PV}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

DEPEND=">=dev-lang/python-2.3"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"
PYTHON_MODNAME="web"

src_test() {
	TESTS="db template net http utils"

	cd "${S}"

	for TEST in ${TESTS}
	do
		${python} web/${TEST}.py || die "Doctest in web/${TEST}.py failed!"
	done
}
