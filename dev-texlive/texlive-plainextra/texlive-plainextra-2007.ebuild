# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-plainextra/texlive-plainextra-2007.ebuild,v 1.15 2008/05/12 19:42:25 nixnut Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
"
TEXLIVE_MODULE_CONTENTS="cellular colortab fixpdfmag fontch hyplain jsmisc newsletr pdcmac plgraph treetex typespec vertex collection-plainextra
"
inherit texlive-module
DESCRIPTION="TeXLive Plain TeX supplementary packages"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-freebsd"
