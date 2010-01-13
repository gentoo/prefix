# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-xetex/texlive-xetex-2009.ebuild,v 1.1 2010/01/11 03:35:22 aballier Exp $

TEXLIVE_MODULE_CONTENTS="arabxetex euenc bidi fontspec fontwrap harvardkyoto mathspec philokalia polyglossia xecjk xecolour xecyr xeindex xepersian xesearch xetex xetex-def xetex-itrans xetex-pstricks xetexconfig xetexfontinfo xltxtra xunicode collection-xetex
"
TEXLIVE_MODULE_DOC_CONTENTS="arabxetex.doc euenc.doc bidi.doc fontspec.doc fontwrap.doc mathspec.doc philokalia.doc polyglossia.doc xecjk.doc xecolour.doc xecyr.doc xeindex.doc xepersian.doc xesearch.doc xetex.doc xetex-itrans.doc xetex-pstricks.doc xetexfontinfo.doc xltxtra.doc xunicode.doc "
TEXLIVE_MODULE_SRC_CONTENTS="euenc.source bidi.source fontspec.source philokalia.source polyglossia.source xecjk.source xepersian.source xltxtra.source "
inherit texlive-module
DESCRIPTION="TeXLive XeTeX packages"

LICENSE="GPL-2 Apache-2.0 as-is GPL-1 LPPL-1.3 OFL public-domain "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
!=app-text/texlive-core-2007*
"
RDEPEND="${DEPEND} "
