# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-tex/latex-beamer/latex-beamer-3.07.ebuild,v 1.22 2008/03/15 23:05:27 coldwind Exp $

EAPI="prefix"

inherit latex-package

DESCRIPTION="LaTeX class for creating presentations using a video projector."
HOMEPAGE="http://latex-beamer.sourceforge.net/"
SRC_URI="mirror://sourceforge/latex-beamer/${P}.tar.gz"

LICENSE="GPL-2 FDL-1.2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

IUSE="doc examples lyx"

DEPEND="lyx? ( app-office/lyx )
	|| ( dev-texlive/texlive-latex >=app-text/tetex-3.0 )"
RDEPEND=">=dev-tex/pgf-1.10"

src_install() {
	insinto /usr/share/texmf-site/tex/latex/beamer
	doins -r base extensions themes || die "could not install themes"

	insinto /usr/share/texmf-site/tex/latex/beamer/emulation
	doins emulation/*.sty || die "could not install styles"

	if use lyx ; then
		insinto /usr/share/lyx/examples
		doins examples/lyx-based-presentation/* || \
			die "could not install lyx-examples"
	fi

	dodoc AUTHORS ChangeLog README TODO doc/licenses/LICENSE

	if use doc ; then
		insinto /usr/share/doc/${PF}/doc
		doins doc/* || die "could not install doc"
	fi

	if use examples ; then
		rm -f "${S}"/examples/a-lecture/{*.tex~,._beamerexample-lecture-pic*}
		if ! use lyx ; then
			einfo "Removing lyx examples as lyx useflag is not set"
			find "${S}" -name "*.lyx" -print -delete
		fi
		insinto /usr/share/doc/${PF}
		doins -r examples emulation/examples solutions || \
			die "could not install examples"
	fi
}
