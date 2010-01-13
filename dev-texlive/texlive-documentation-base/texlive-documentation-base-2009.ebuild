# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-documentation-base/texlive-documentation-base-2009.ebuild,v 1.1 2010/01/11 03:07:00 aballier Exp $

TEXLIVE_MODULE_CONTENTS="texlive-common texlive-en collection-documentation-base
"
TEXLIVE_MODULE_DOC_CONTENTS="texlive-common.doc texlive-en.doc "
TEXLIVE_MODULE_SRC_CONTENTS=""
inherit texlive-module
DESCRIPTION="TeXLive TeX Live documentation"

LICENSE="GPL-2 "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=""
RDEPEND="${DEPEND} "
