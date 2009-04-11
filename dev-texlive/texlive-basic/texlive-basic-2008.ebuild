# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-basic/texlive-basic-2008.ebuild,v 1.10 2009/03/18 20:56:15 ranger Exp $

TEXLIVE_MODULE_CONTENTS="ams amsfonts bibtex cm cmex dvips enctex etex etex-pkg hyph-utf8 makeindex metafont mflogo misc plain hyphen-base bin-tex bin-metafont collection-basic
"
TEXLIVE_MODULE_DOC_CONTENTS="amsfonts.doc bibtex.doc cm.doc enctex.doc etex.doc etex-pkg.doc hyph-utf8.doc makeindex.doc mflogo.doc bin-tex.doc bin-metafont.doc "
TEXLIVE_MODULE_SRC_CONTENTS="amsfonts.source hyph-utf8.source mflogo.source "
inherit texlive-module
DESCRIPTION="TeXLive Essential programs and files"

LICENSE="GPL-2 as-is GPL-1 LPPL-1.3 TeX "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-documentation-base-2008
!=app-text/texlive-core-2007*
"
RDEPEND="${DEPEND}"
