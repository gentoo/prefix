# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/m2crypto/m2crypto-0.19.1.ebuild,v 1.1 2009/05/16 06:17:59 arfrever Exp $

EAPI="2"

inherit distutils eutils multilib portability

MY_PN="M2Crypto"

DESCRIPTION="A python wrapper for the OpenSSL crypto library"
HOMEPAGE="http://chandlerproject.org/bin/view/Projects/MeTooCrypto"
SRC_URI="http://pypi.python.org/packages/source/${MY_PN:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc"

RDEPEND=">=dev-libs/openssl-0.9.8"
DEPEND="${RDEPEND}
	>=dev-lang/swig-1.3.25
	doc? ( dev-python/epydoc )
	dev-python/setuptools"

PYTHON_MODNAME="${MY_PN}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.18.2-resume_session.patch"
}

src_install() {
	DOCS="CHANGES INSTALL"
	distutils_src_install

	if use doc; then
		cd "${S}/demo"
		treecopy . "${ED}/usr/share/doc/${PF}/example"

		einfo "Generating API docs as requested..."
		cd "${S}/doc"
		distutils_python_version
		export PYTHONPATH="${PYTHONPATH}:${ED}/usr/$(get_libdir)/python${PYVER}/site-packages"
		einfo "${PYTHONPATH}"
		epydoc --html --output=api --name=M2Crypto M2Crypto
	fi
	dohtml -r *
}

src_test() {
	"${python}" setup.py test || die "test failed"
}
