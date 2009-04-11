# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-xetex/texlive-xetex-2007.ebuild,v 1.17 2008/09/09 18:41:10 aballier Exp $

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
"
TEXLIVE_MODULE_CONTENTS="euenc fontspec ifxetex philokalia xetex xetexconfig xetexurl xltxtra xunicode collection-xetex
"
inherit texlive-module
DESCRIPTION="TeXLive XeTeX macros"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

RDEPEND=">=app-text/xdvipdfmx-0.4"
IUSE=""
