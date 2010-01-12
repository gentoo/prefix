# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-texinfo/texlive-texinfo-2009.ebuild,v 1.1 2010/01/11 03:35:01 aballier Exp $

TEXLIVE_MODULE_CONTENTS="texinfo collection-texinfo
"
TEXLIVE_MODULE_DOC_CONTENTS=""
TEXLIVE_MODULE_SRC_CONTENTS=""
inherit texlive-module
DESCRIPTION="TeXLive GNU Texinfo"

LICENSE="GPL-2 GPL-1 "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
"
RDEPEND="${DEPEND} dev-texlive/texlive-genericrecommended"
