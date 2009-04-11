# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-texinfo/texlive-texinfo-2007.ebuild,v 1.17 2009/02/02 07:16:33 aballier Exp $

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic dev-texlive/texlive-genericrecommended"
TEXLIVE_MODULE_CONTENTS="bin-texinfo texinfo collection-texinfo
"
inherit texlive-module
DESCRIPTION="TeXLive GNU Texinfo"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
