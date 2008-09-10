# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-langgerman/texlive-langgerman-2008.ebuild,v 1.1 2008/09/09 16:36:43 aballier Exp $

EAPI="prefix"

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
"
TEXLIVE_MODULE_CONTENTS="dehyph-exptl german germbib mkind-german r_und_s uhrzeit umlaute hyphen-german collection-langgerman
"
TEXLIVE_MODULE_DOC_CONTENTS="dehyph-exptl.doc german.doc germbib.doc r_und_s.doc umlaute.doc "
TEXLIVE_MODULE_SRC_CONTENTS="german.source umlaute.source "
inherit texlive-module
DESCRIPTION="TeXLive German"

LICENSE="GPL-2 as-is freedist LPPL-1.3 "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
