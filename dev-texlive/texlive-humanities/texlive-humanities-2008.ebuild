# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-humanities/texlive-humanities-2008.ebuild,v 1.10 2009/03/18 21:06:30 ranger Exp $

TEXLIVE_MODULE_CONTENTS="alnumsec arydshln bibleref covington dramatist ecltree ednotes gb4e jura juraabbrev juramisc jurarsp ledmac lexikon lineno linguex numline parallel parrun plari play poemscol qobitree qtree rtklage screenplay sides stage tree-dvips verse xyling collection-humanities
"
TEXLIVE_MODULE_DOC_CONTENTS="alnumsec.doc arydshln.doc bibleref.doc covington.doc dramatist.doc ecltree.doc ednotes.doc gb4e.doc jura.doc juraabbrev.doc juramisc.doc jurarsp.doc ledmac.doc lexikon.doc lineno.doc linguex.doc parallel.doc parrun.doc plari.doc play.doc poemscol.doc qobitree.doc qtree.doc rtklage.doc screenplay.doc sides.doc stage.doc tree-dvips.doc verse.doc xyling.doc "
TEXLIVE_MODULE_SRC_CONTENTS="alnumsec.source arydshln.source bibleref.source dramatist.source jura.source juraabbrev.source jurarsp.source ledmac.source lexikon.source parallel.source parrun.source plari.source play.source poemscol.source screenplay.source tree-dvips.source verse.source "
inherit texlive-module
DESCRIPTION="TeXLive Humanities packages"

LICENSE="GPL-2 freedist GPL-1 LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
DEPEND="!dev-tex/lineno
"
RDEPEND="${DEPEND}"
