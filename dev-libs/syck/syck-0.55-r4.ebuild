# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/syck/syck-0.55-r4.ebuild,v 1.11 2008/08/09 21:35:20 hoffie Exp $

inherit flag-o-matic distutils

IUSE="php python"
DESCRIPTION="Syck is an extension for reading and writing YAML swiftly in popular scripting languages."
HOMEPAGE="http://whytheluckystiff.net/syck/"
SRC_URI="http://rubyforge.org/frs/download.php/4492/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
DEPEND="python? ( dev-lang/python !dev-python/pysyck )"
RDEPEND="${DEPEND}"
PDEPEND="php? ( dev-php5/pecl-syck
		    !=dev-libs/syck-0.55-r1 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/syck-0.55-64bit.patch"
}
src_compile() {
	append-flags -fPIC
	econf
	emake

	if use python; then
		pushd ext/python
		distutils_src_compile
		popd
	fi
}

src_install() {
	einstall

	if use python; then
		pushd ext/python
		distutils_src_install
		popd
	fi
}
