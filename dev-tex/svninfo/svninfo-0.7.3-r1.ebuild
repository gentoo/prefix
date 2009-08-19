# Copyright 2005-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/svninfo/svninfo-0.7.3-r1.ebuild,v 1.16 2009/03/18 19:11:24 armin76 Exp $

inherit latex-package eutils

LICENSE="LPPL-1.2"
DESCRIPTION="A LaTeX module to acces SVN version info"
HOMEPAGE="http://www.brucker.ch/projects/svninfo/index.en.html"
SRC_URI="http://www.brucker.ch/projects/svninfo/download/${P}.tar.gz"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

DOCS="README"

TEXMF=/usr/share/texmf-site

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-0.5-latex-compile.patch"
}

src_compile() {
	export VARTEXFONTS="${T}/fonts"
	emake -j1 || die "compilation failed"
}
