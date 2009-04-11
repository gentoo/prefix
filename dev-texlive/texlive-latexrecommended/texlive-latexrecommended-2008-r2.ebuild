# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-latexrecommended/texlive-latexrecommended-2008-r2.ebuild,v 1.9 2009/03/18 21:17:16 ranger Exp $

TEXLIVE_MODULE_CONTENTS="anysize  booktabs caption cite citeref cmap crop ctable ec eso-pic euler extsizes fancybox fancyref fancyvrb float fp ifxetex index jknapltx koma-script listings mdwtools memoir microtype ms ntgclass oberdiek pdfpages powerdot psfrag rcs rotating seminar setspace subfig thumbpdf  xkeyval collection-latexrecommended
"
TEXLIVE_MODULE_DOC_CONTENTS="anysize.doc booktabs.doc caption.doc cite.doc cmap.doc crop.doc ctable.doc ec.doc eso-pic.doc euler.doc extsizes.doc fancybox.doc fancyref.doc fancyvrb.doc float.doc fp.doc ifxetex.doc index.doc jknapltx.doc koma-script.doc listings.doc mdwtools.doc memoir.doc microtype.doc ms.doc ntgclass.doc oberdiek.doc pdfpages.doc powerdot.doc psfrag.doc rcs.doc rotating.doc seminar.doc subfig.doc thumbpdf.doc xkeyval.doc "
TEXLIVE_MODULE_SRC_CONTENTS="booktabs.source caption.source crop.source ctable.source eso-pic.source euler.source fancyref.source fancyvrb.source float.source index.source koma-script.source listings.source mdwtools.source memoir.source microtype.source ms.source ntgclass.source oberdiek.source pdfpages.source powerdot.source psfrag.source rcs.source rotating.source subfig.source xkeyval.source "
inherit texlive-module
DESCRIPTION="TeXLive LaTeX recommended packages"

LICENSE="GPL-2 Artistic-2 as-is freedist GPL-1 LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2008
!dev-tex/xkeyval
!dev-tex/memoir
!dev-tex/listings
!=dev-texlive/texlive-latexextra-2007*
!=app-text/texlive-core-2007*
!=dev-texlive/texlive-xetex-2008
"
RDEPEND="${DEPEND} "
TEXLIVE_MODULE_BINSCRIPTS="texmf-dist/scripts/oberdiek/pdfatfi.pl texmf-dist/scripts/thumbpdf/thumbpdf.pl"
