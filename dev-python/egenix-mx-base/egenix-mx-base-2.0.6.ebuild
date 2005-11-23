# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/egenix-mx-base/egenix-mx-base-2.0.6.ebuild,v 1.3 2005/08/17 22:35:37 matsuu Exp $

EAPI="prefix"

inherit distutils flag-o-matic

DESCRIPTION="egenix utils for Python"
HOMEPAGE="http://www.egenix.com/"
SRC_URI="http://www.egenix.com/files/python/${P}.tar.gz"

LICENSE="eGenixPublic"
SLOT="0"
KEYWORDS="~x86 ~ppc ~sparc ~mips ~alpha ~arm ~hppa ~amd64 ~ia64 ~ppc-macos ~ppc64 ~s390 ~sh"
IUSE=""

DEPEND="virtual/python"

src_unpack() {
	unpack ${A}
	# doesn't play well with -fstack-protector (#63762)
	rm ${S}/mx/TextTools/Examples/pytag.py
}

src_compile() {
	replace-flags "-O[3s]" "-O2"
	distutils_src_compile
}

src_install() {
	distutils_src_install
	dohtml -a html -r mx
}
