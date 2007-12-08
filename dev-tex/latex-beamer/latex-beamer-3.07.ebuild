# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/latex-beamer/latex-beamer-3.07.ebuild,v 1.10 2007/10/26 20:20:44 armin76 Exp $

EAPI="prefix"

inherit latex-package

DESCRIPTION="LaTeX class for creating presentations using a video projector."
HOMEPAGE="http://latex-beamer.sourceforge.net/"
SRC_URI="mirror://sourceforge/latex-beamer/${P}.tar.gz"

LICENSE="GPL-2 FDL-1.2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"

IUSE="doc lyx"

DEPEND="lyx? ( app-office/lyx )
	|| ( dev-texlive/texlive-latex >=app-text/tetex-3.0 )"
RDEPEND=">=dev-tex/pgf-1.10"

src_install() {
	insinto "${ROOT}"/usr/share/texmf-site/tex/latex/beamer
	doins -r base extensions themes || die "could not install themes"

	insinto "${ROOT}"/usr/share/texmf-site/tex/latex/beamer/emulation
	doins emulation/*.sty || die "could not install styles"

	if use lyx ; then
		insinto "${ROOT}"/usr/share/lyx/examples
		doins examples/lyx-based-presentation/* || \
			die "could not install lyx-examples"
	fi

	dodoc AUTHORS ChangeLog README TODO doc/licenses/LICENSE
	if use doc ; then
		insinto "${ROOT}"/usr/share/doc/${PF}
		doins doc/* || die "could not install doc"

		insinto "${ROOT}"/usr/share/doc/${PF}
		doins -r examples emulation/examples solutions || \
			die "could not install doc"

		prepalldocs
	fi
}
