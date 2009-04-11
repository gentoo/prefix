# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-latexrecommended/texlive-latexrecommended-2007.ebuild,v 1.19 2008/10/04 08:54:52 aballier Exp $

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-latex
!dev-tex/xkeyval
!dev-tex/floatflt
!dev-tex/listings
!dev-tex/memoir"
TEXLIVE_MODULE_CONTENTS="anysize booktabs caption cite citeref cmap crop ctable ec eso-pic euler everysel everyshi extsizes fancyref fancyvrb float floatflt fp index jknapltx koma-script listings mdwtools memoir microtype ntgclass oberdiek pdfpages powerdot psfrag rcs rotating seminar setspace subfig thumbpdf ucs xkeyval collection-latexrecommended
"
inherit texlive-module
DESCRIPTION="TeXLive LaTeX recommended packages"

LICENSE="GPL-2 LPPL-1.3c Artistic Artistic-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
