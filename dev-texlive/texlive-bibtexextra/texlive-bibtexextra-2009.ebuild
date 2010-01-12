# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-bibtexextra/texlive-bibtexextra-2009.ebuild,v 1.1 2010/01/11 03:06:17 aballier Exp $

TEXLIVE_MODULE_CONTENTS="aichej amsrefs apacite apalike2 beebe bibarts bibexport bibhtml biblist bibtopic bibtopicprefix bibunits cell chicago chicago-annote chembst collref compactbib custom-bib din1505 dk-bib doipubmed elsevier-bib fbs figbib footbib harvard harvmac ijqc inlinebib iopart-num jneurosci jurabib listbib margbib multibib munich notes2bib perception pnas2009 rsc sort-by-letters splitbib urlbst collection-bibtexextra
"
TEXLIVE_MODULE_DOC_CONTENTS="amsrefs.doc apacite.doc bibarts.doc bibexport.doc bibhtml.doc biblist.doc bibtopic.doc bibtopicprefix.doc bibunits.doc cell.doc chicago-annote.doc chembst.doc collref.doc custom-bib.doc din1505.doc dk-bib.doc doipubmed.doc elsevier-bib.doc figbib.doc footbib.doc harvard.doc harvmac.doc ijqc.doc inlinebib.doc iopart-num.doc jneurosci.doc jurabib.doc listbib.doc margbib.doc multibib.doc munich.doc notes2bib.doc perception.doc rsc.doc sort-by-letters.doc splitbib.doc urlbst.doc "
TEXLIVE_MODULE_SRC_CONTENTS="amsrefs.source apacite.source bibarts.source bibexport.source biblist.source bibtopic.source bibtopicprefix.source bibunits.source chembst.source collref.source custom-bib.source dk-bib.source doipubmed.source footbib.source harvard.source jurabib.source listbib.source margbib.source multibib.source notes2bib.source rsc.source splitbib.source urlbst.source "
inherit texlive-module
DESCRIPTION="TeXLive Extra BibTeX styles"

LICENSE="GPL-2 as-is GPL-1 LPPL-1.3 "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2009
!=dev-texlive/texlive-latexextra-2007*
!<dev-texlive/texlive-latex-2009
"
RDEPEND="${DEPEND} "
