# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/egenix-mx-base/egenix-mx-base-3.1.2.ebuild,v 1.6 2009/09/20 17:44:40 armin76 Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils flag-o-matic

DESCRIPTION="eGenix utils for Python"
HOMEPAGE="http://www.egenix.com/products/python/mxBase"
SRC_URI="http://downloads.egenix.com/python/${P}.tar.gz"

LICENSE="eGenixPublic-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

RESTRICT_PYTHON_ABIS="3*"

PYTHON_MODNAME="mx"

src_prepare() {
	distutils_src_prepare
	# doesn't play well with -fstack-protector (#63762)
	rm "mx/TextTools/Examples/pytag.py"

	# We do the optimization ourselves
	sed -i \
		-e 's/^\(optimize\) = 1/\1 = 0/' \
		setup.cfg || die "sed failed"

	# And we don't want the docs in site-packages
	sed -i \
		-e '/\/Doc\//d' \
		egenix_mx_base.py || die "sed failed"
}

src_compile() {
	replace-flags "-O[3s]" "-O2"
	distutils_src_compile
}

src_install() {
	distutils_src_install
	dohtml -a html -r mx
	insinto /usr/share/doc/${PF}
	find "${S}" -iname "*.pdf" | xargs doins

	installation_of_headers() {
		dodir "$(python_get_includedir)/mx"
		find "${ED}$(python_get_sitedir)/mx" -type f -name "*.h" -print0 | while read -d $'\0' header; do
			mv -f "${header}" "${ED}$(python_get_includedir)/mx"
		done
	}
	python_execute_function --action-message 'Installation of headers with Python ${PYTHON_ABI}' installation_of_headers
}
