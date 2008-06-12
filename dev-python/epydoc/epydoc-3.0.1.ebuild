# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/epydoc/epydoc-3.0.1.ebuild,v 1.2 2008/05/12 09:45:31 aballier Exp $

EAPI="prefix"

inherit distutils

DESCRIPTION="Tool for generating API documentation for Python modules, based on their docstrings"
HOMEPAGE="http://epydoc.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc latex"

RDEPEND="dev-python/docutils
	latex? ( virtual/latex-base
		|| ( dev-texlive/texlive-latexextra app-text/tetex app-text/ptex )
	)"

src_install() {
	distutils_src_install

	doman man/*
	use doc && dohtml -r doc/*
}
