# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-langpolish/texlive-langpolish-2007.ebuild,v 1.8 2008/02/10 15:42:55 aballier Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-latex
dev-texlive/texlive-fontsextra"
TEXLIVE_MODULE_CONTENTS="antp  bin-mex bin-platex cc-pl gustlib hyphen-polish  mex mwcls ogonek pl platex qfonts qpxqtx tap utf8mex collection-langpolish
"
inherit texlive-module
DESCRIPTION="TeXLive Polish"

LICENSE="GPL-2 LPPL-1.3c Aladdin"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
