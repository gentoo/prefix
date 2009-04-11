# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/m2crypto/m2crypto-0.18.2.ebuild,v 1.6 2009/03/15 13:52:27 ranger Exp $

inherit distutils portability eutils multilib

MY_P="${PN}-${PV%.*}"

DESCRIPTION="A python wrapper for the OpenSSL crypto library"
HOMEPAGE="http://wiki.osafoundation.org/bin/view/Projects/MeTooCrypto"
SRC_URI="http://wiki.osafoundation.org/pub/Projects/MeTooCrypto/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="doc"

RDEPEND=">=dev-libs/openssl-0.9.8"
DEPEND="${RDEPEND}
	>=dev-lang/swig-1.3.25
	doc? ( dev-python/epydoc )
	dev-python/setuptools"

PYTHON_MODNAME="M2Crypto"

src_unpack() {
	distutils_src_unpack
	cd "${S}"

	epatch "${FILESDIR}/${P}-timeval_struct_size.patch"
	epatch "${FILESDIR}/${P}-resume_session.patch"
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
