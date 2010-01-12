# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-langgerman/texlive-langgerman-2009.ebuild,v 1.1 2010/01/11 03:22:48 aballier Exp $

TEXLIVE_MODULE_CONTENTS="dehyph-exptl german germbib germkorr kalender mkind-german r_und_s uhrzeit umlaute hyphen-german collection-langgerman
"
TEXLIVE_MODULE_DOC_CONTENTS="dehyph-exptl.doc german.doc germbib.doc germkorr.doc r_und_s.doc umlaute.doc "
TEXLIVE_MODULE_SRC_CONTENTS="german.source umlaute.source "
inherit texlive-module
DESCRIPTION="TeXLive German"

LICENSE="GPL-2 as-is freedist GPL-1 LPPL-1.3 "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
!<dev-texlive/texlive-latexextra-2009
"
RDEPEND="${DEPEND} "
