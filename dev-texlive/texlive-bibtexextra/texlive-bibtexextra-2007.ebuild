# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-bibtexextra/texlive-bibtexextra-2007.ebuild,v 1.16 2008/09/09 17:59:43 aballier Exp $

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-latex
"
TEXLIVE_MODULE_CONTENTS="apacite beebe bibarts bibhtml biblist bibtopic bibunits compactbib custom-bib doipubmed elsevier-bib footbib harvard harvmac ijqc inlinebib iopart-num jneurosci jurabib listbib multibib munich perception rsc sort-by-letters urlbst collection-bibtexextra
"
inherit texlive-module
DESCRIPTION="TeXLive Extra BibTeX styles"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
