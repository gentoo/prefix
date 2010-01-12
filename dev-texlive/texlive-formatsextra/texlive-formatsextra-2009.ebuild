# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-formatsextra/texlive-formatsextra-2009.ebuild,v 1.1 2010/01/11 03:16:52 aballier Exp $

TEXLIVE_MODULE_CONTENTS="alatex edmac eplain mltex physe phyzzx psizzl startex texsis ytex collection-formatsextra
"
TEXLIVE_MODULE_DOC_CONTENTS="alatex.doc edmac.doc eplain.doc mltex.doc phyzzx.doc psizzl.doc startex.doc texsis.doc "
TEXLIVE_MODULE_SRC_CONTENTS="alatex.source edmac.source eplain.source psizzl.source startex.source "
inherit texlive-module
DESCRIPTION="TeXLive Extra formats"

LICENSE="GPL-2 as-is freedist GPL-1 LPPL-1.3 public-domain TeX "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
>=dev-texlive/texlive-latex-2008
"
RDEPEND="${DEPEND} "
