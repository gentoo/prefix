# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-basic/texlive-basic-2007.ebuild,v 1.6 2007/10/26 19:22:06 fmccor Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="
dev-texlive/texlive-documentation-base
"
TEXLIVE_MODULE_CONTENTS="ams amsfonts bibtex cm cmex dvips enctex etex fontname hyphen-base lm makeindex metafont mflogo misc plain xu-hyphen collection-basic
"
inherit texlive-module
DESCRIPTION="TeXLive Essential programs and files"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
