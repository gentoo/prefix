# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/pgf/pgf-1.18.ebuild,v 1.14 2008/03/15 23:03:28 coldwind Exp $

inherit latex-package

DESCRIPTION="pgf -- The TeX Portable Graphic Format"
HOMEPAGE="http://sourceforge.net/projects/pgf"
SRC_URI="mirror://sourceforge/pgf/${P}.tar.gz"

LICENSE="GPL-2 LPPL-1.3c FDL-1.2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc"
DEPEND="|| ( ( dev-texlive/texlive-latexrecommended >=dev-tex/xcolor-2.11 )
	>=app-text/tetex-3.0
	)"

TEXMF="/usr/share/texmf-site"

src_install() {
	insinto ${TEXMF}/tex/
	for dir in generic latex plain ; do
		doins -r ${dir} || die "Failed installing"
	done

	cd "${S}/doc/generic/pgf"
	dodoc AUTHORS ChangeLog README TODO licenses/LICENSE
	if use doc ; then
		insinto /usr/share/doc/${PF}
		doins -r images macros text-en version-for-dvipdfm version-for-dvips \
			version-for-pdftex version-for-tex4ht version-for-vtex || die \
			"Failed to install documentation"
		prepalldocs
	fi
}
