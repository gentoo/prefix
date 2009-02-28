# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-langdutch/texlive-langdutch-2008.ebuild,v 1.3 2009/02/27 15:22:05 fmccor Exp $

EAPI="prefix"

TEXLIVE_MODULE_CONTENTS="hyphen-dutch collection-langdutch
"
TEXLIVE_MODULE_DOC_CONTENTS=""
TEXLIVE_MODULE_SRC_CONTENTS=""
inherit texlive-module
DESCRIPTION="TeXLive Dutch"

LICENSE="GPL-2 "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2008
"
RDEPEND="${DEPEND}"
