# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-langpolish/texlive-langpolish-2009.ebuild,v 1.1 2010/01/11 03:26:53 aballier Exp $

TEXLIVE_MODULE_CONTENTS="cc-pl gustlib gustprog mex mwcls pl polski qpxqtx tap utf8mex hyphen-polish collection-langpolish
"
TEXLIVE_MODULE_DOC_CONTENTS="cc-pl.doc gustlib.doc gustprog.doc mex.doc mwcls.doc pl.doc polski.doc qpxqtx.doc tap.doc utf8mex.doc "
TEXLIVE_MODULE_SRC_CONTENTS="mex.source mwcls.source polski.source tap.source "
inherit texlive-module
DESCRIPTION="TeXLive Polish"

LICENSE="GPL-2 LPPL-1.3 public-domain TeX "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2009
>=dev-texlive/texlive-basic-2009
"
RDEPEND="${DEPEND} "
