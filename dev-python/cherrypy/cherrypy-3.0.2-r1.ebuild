# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/cherrypy/cherrypy-3.0.2-r1.ebuild,v 1.2 2008/01/08 17:16:21 armin76 Exp $

EAPI="prefix"

inherit eutils distutils

MY_P=CherryPy-${PV}

DESCRIPTION="CherryPy is a pythonic, object-oriented web development framework."
SRC_URI="http://download.cherrypy.org/cherrypy/${PV}/${MY_P}.tar.gz"
HOMEPAGE="http://www.cherrypy.org/"
IUSE="doc"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
LICENSE="BSD"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-invalidsession.patch
	sed -i \
		-e 's/"cherrypy.tutorial",//' \
		-e "/('cherrypy\/tutorial',/, /),/d" \
		setup.py || die "sed failed"

}

src_install() {
	distutils_src_install
	if use doc ; then
		insinto /usr/share/doc/${PF}
		doins -r cherrypy/tutorial
	fi
}

src_test() {
	PYTHONPATH=. "${python}" cherrypy/test/test.py --dumb || die "test failed"
}
