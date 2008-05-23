# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-python/mako/mako-0.1.10.ebuild,v 1.3 2008/05/02 05:06:39 pythonhead Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="A python templating language."
HOMEPAGE="http://www.makotemplates.org/"
MY_P="Mako-${PV}"
SRC_URI="http://www.makotemplates.org/downloads/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc test"

DEPEND=""
RDEPEND=""
S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install
	use doc && dohtml doc/*html doc/*css
}

src_test() {
	PYTHONPATH="./lib" "${python}" test/alltests.py || die "tests failed"
}
