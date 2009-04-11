# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/latexsuite/latexsuite-1.5.20060325.ebuild,v 1.9 2008/09/12 22:23:44 maekke Exp $

inherit vim-plugin versionator

DESCRIPTION="vim plugin: a comprehensive set of tools to view, edit and compile LaTeX documents"
HOMEPAGE="http://vim-latex.sourceforge.net/"

LICENSE="vim"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

# See bug #112326 for why we have this nasty hack
MY_P="latexSuite$(get_version_component_range 3- )"
S="${WORKDIR}"
SRC_URI="http://vim-latex.sourceforge.net/download/${MY_P}.tar.gz"

RDEPEND="virtual/latex-base"

VIM_PLUGIN_HELPFILES="latex-suite.txt latex-suite-quickstart.txt latexhelp.txt imaps.txt"

src_install() {
	into /usr
	dobin ltags
	rm ltags
	vim-plugin_src_install
}

pkg_postinst() {
	vim-plugin_pkg_postinst
	elog
	elog "To use the latexSuite plugin add:"
	elog "   filetype plugin on"
	elog '   set grepprg=grep\ -nH\ $*'
	elog "to your ~/.vimrc-file"
	elog
}
