# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-latexrecommended/texlive-latexrecommended-2007.ebuild,v 1.6 2007/10/26 19:21:47 fmccor Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-latex
!dev-tex/extsizes
!dev-tex/koma-script
!dev-tex/xkeyval
!dev-tex/floatflt
!dev-tex/memoir"
TEXLIVE_MODULE_CONTENTS="anysize booktabs caption cite citeref cmap crop ctable ec eso-pic euler everysel everyshi extsizes fancyref fancyvrb float floatflt fp index jknapltx koma-script listings mdwtools memoir microtype ntgclass oberdiek pdfpages powerdot psfrag rcs rotating seminar setspace subfig thumbpdf ucs xkeyval collection-latexrecommended
"
inherit texlive-module
DESCRIPTION="TeXLive LaTeX recommended packages"

LICENSE="GPL-2 LPPL-1.3c Artistic Artistic-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
