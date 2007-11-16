# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-psutils/texlive-psutils-2007.ebuild,v 1.6 2007/10/26 19:22:19 fmccor Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS=""
TEXLIVE_MODULE_CONTENTS="bin-getafm bin-lcdftypetools bin-pstools bin-psutils bin-t1utils bin-ttf2pt1 dvipsconfig collection-psutils
"
inherit texlive-module
DESCRIPTION="TeXLive PostScript and Truetype utilities"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
