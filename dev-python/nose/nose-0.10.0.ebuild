# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/nose/nose-0.10.0.ebuild,v 1.1 2007/10/14 11:53:59 hawking Exp $

EAPI="prefix"

inherit distutils eutils

DESCRIPTION="A unittest extension offering automatic test suite discovery and easy test authoring"
HOMEPAGE="http://somethingaboutorange.com/mrl/projects/nose/"
SRC_URI="http://somethingaboutorange.com/mrl/projects/nose/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE="doc examples test"

RDEPEND="dev-python/setuptools"
DEPEND="${RDEPEND}
	test? ( dev-python/twisted )"

src_unpack() {
	distutils_src_unpack

	# Disable tests that access the network
	epatch "${FILESDIR}/${P}-tests-nonetwork.patch"
}

src_install() {
	DOCS="AUTHORS"
	distutils_src_install --install-data "${EPREFIX}"/usr/share

	use doc && dohtml doc/*

	if use examples ; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	PYTHONPATH=. "${python}" setup.py test || die "test failed"
}
