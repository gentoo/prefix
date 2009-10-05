# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/epydoc/epydoc-2.1-r2.ebuild,v 1.20 2009/10/03 05:33:08 arfrever Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Tool for generating API documentation for Python modules, based on their docstrings"
HOMEPAGE="http://epydoc.sourceforge.net/"
SRC_URI="mirror://sourceforge/epydoc/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc latex"

DEPEND=""
RDEPEND="latex? ( virtual/latex-base
		|| ( dev-texlive/texlive-latexextra app-text/ptex ) )"
RESTRICT_PYTHON_ABIS="3.*"

src_install() {
	distutils_src_install

	doman man/*
	use doc && dohtml -r doc/*
}
