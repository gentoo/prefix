# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-latex3/texlive-latex3-2007.ebuild,v 1.16 2008/09/09 18:33:02 aballier Exp $

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-latex
"
TEXLIVE_MODULE_CONTENTS="galley template xinitials xor xparse xtab xtcapts xtheorem collection-latex3
"
inherit texlive-module
DESCRIPTION="TeXLive LaTeX3 packages"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
