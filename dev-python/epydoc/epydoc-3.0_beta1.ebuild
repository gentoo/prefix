# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/epydoc/epydoc-3.0_beta1.ebuild,v 1.2 2008/01/18 00:29:43 pythonhead Exp $

EAPI="prefix"

inherit distutils versionator

MY_P=$(delete_version_separator "_" ${P})

DESCRIPTION="Tool for generating API documentation for Python modules, based on their docstrings"
HOMEPAGE="http://epydoc.sourceforge.net/"
SRC_URI="mirror://sourceforge/epydoc/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc pdf"

RDEPEND="dev-python/docutils
	pdf? ( virtual/tetex )"

S="${WORKDIR}/${MY_P}"
src_install() {
	distutils_src_install
	doman "${S}/man/*"
	use doc && dohtml -r "${S}/doc/*"
}
