# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-bibtexextra/texlive-bibtexextra-2008.ebuild,v 1.10 2009/03/18 20:59:54 ranger Exp $

TEXLIVE_MODULE_CONTENTS="aichej apacite beebe bibarts bibhtml biblist bibtopic bibtopicprefix bibunits chicago compactbib custom-bib din1505 dk-bib doipubmed elsevier-bib fbs figbib footbib harvard harvmac ijqc inlinebib iopart-num jneurosci jurabib listbib multibib munich notes2bib perception rsc sort-by-letters splitbib urlbst collection-bibtexextra
"
TEXLIVE_MODULE_DOC_CONTENTS="apacite.doc bibarts.doc bibhtml.doc biblist.doc bibtopic.doc bibtopicprefix.doc bibunits.doc custom-bib.doc din1505.doc dk-bib.doc doipubmed.doc elsevier-bib.doc figbib.doc footbib.doc harvard.doc harvmac.doc ijqc.doc inlinebib.doc iopart-num.doc jneurosci.doc jurabib.doc listbib.doc multibib.doc munich.doc notes2bib.doc perception.doc rsc.doc sort-by-letters.doc splitbib.doc urlbst.doc "
TEXLIVE_MODULE_SRC_CONTENTS="apacite.source bibarts.source biblist.source bibtopic.source bibtopicprefix.source bibunits.source custom-bib.source dk-bib.source doipubmed.source footbib.source harvard.source jurabib.source listbib.source multibib.source notes2bib.source rsc.source splitbib.source urlbst.source "
inherit texlive-module
DESCRIPTION="TeXLive Extra BibTeX styles"

LICENSE="GPL-2 as-is freedist GPL-1 LPPL-1.3 "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2008
!=dev-texlive/texlive-latexextra-2007*
"
RDEPEND="${DEPEND}"
