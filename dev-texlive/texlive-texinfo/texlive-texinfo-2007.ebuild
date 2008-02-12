# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-texinfo/texlive-texinfo-2007.ebuild,v 1.8 2008/02/10 16:05:05 aballier Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
"
TEXLIVE_MODULE_CONTENTS="bin-texinfo texinfo collection-texinfo
"
inherit texlive-module
DESCRIPTION="TeXLive GNU Texinfo"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
