# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-plainextra/texlive-plainextra-2009.ebuild,v 1.1 2010/01/11 03:33:31 aballier Exp $

TEXLIVE_MODULE_CONTENTS="figflow fixpdfmag font-change fontch graphics-pln hyplain js-misc mkpattern newsletr placeins-plain plnfss resumemac timetable treetex typespec varisize collection-plainextra
"
TEXLIVE_MODULE_DOC_CONTENTS="figflow.doc font-change.doc fontch.doc graphics-pln.doc hyplain.doc js-misc.doc mkpattern.doc newsletr.doc plnfss.doc resumemac.doc treetex.doc typespec.doc varisize.doc "
TEXLIVE_MODULE_SRC_CONTENTS="graphics-pln.source "
inherit texlive-module
DESCRIPTION="TeXLive Plain TeX supplementary packages"

LICENSE="GPL-2 as-is freedist LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
!<dev-texlive/texlive-langvietnamese-2009
"
RDEPEND="${DEPEND} "
