# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-genericextra/texlive-genericextra-2009.ebuild,v 1.1 2010/01/11 03:17:35 aballier Exp $

TEXLIVE_MODULE_CONTENTS="abbr abstyles barr borceux c-pascal colorsep dinat dirtree eijkhout encxvlna fenixpar fltpoint insbox mathdots metatex mftoeps midnight multi ofs pdf-trans shade tabto-generic vrb vtex xlop collection-genericextra
"
TEXLIVE_MODULE_DOC_CONTENTS="abbr.doc abstyles.doc barr.doc borceux.doc c-pascal.doc dinat.doc dirtree.doc encxvlna.doc fenixpar.doc fltpoint.doc insbox.doc mathdots.doc metatex.doc midnight.doc ofs.doc pdf-trans.doc shade.doc vrb.doc xlop.doc "
TEXLIVE_MODULE_SRC_CONTENTS="borceux.source dirtree.source fltpoint.source mathdots.source mftoeps.source xlop.source "
inherit texlive-module
DESCRIPTION="TeXLive Extra generic packages"

LICENSE="GPL-2 as-is freedist GPL-1 LPPL-1.3 public-domain TeX "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
"
RDEPEND="${DEPEND} "
