# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/latexsuite/latexsuite-1.5.20060325.ebuild,v 1.2 2006/09/23 10:51:33 corsair Exp $

EAPI="prefix"

inherit vim-plugin versionator

DESCRIPTION="vim plugin: a comprehensive set of tools to view, edit and compile LaTeX documents"
HOMEPAGE="http://vim-latex.sourceforge.net/"

LICENSE="vim"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

# See bug #112326 for why we have this nasty hack
MY_P="latexSuite$(get_version_component_range 3- )"
S="${WORKDIR}"
SRC_URI="http://vim-latex.sourceforge.net/download/${MY_P}.tar.gz"

RDEPEND="virtual/tetex"

VIM_PLUGIN_HELPFILES="latex-suite.txt latex-suite-quickstart.txt latexhelp.txt imaps.txt"

src_install() {
	into /usr
	dobin ltags
	rm ltags
	vim-plugin_src_install
}

pkg_postinst() {
	vim-plugin_pkg_postinst
	einfo
	einfo "To use the latexSuite plugin add:"
	einfo "   filetype plugin on"
	einfo '   set grepprg=grep\ -nH\ $*'
	einfo "to your ~/.vimrc-file"
	einfo
}

