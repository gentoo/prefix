# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-metapost/texlive-metapost-2008.ebuild,v 1.10 2009/03/18 20:57:32 ranger Exp $

TEXLIVE_MODULE_CONTENTS="automata bbcard blockdraw_mp bpolynomial cmarrows dviincl emp epsincl expressg exteps featpost hatching latexmp metaobj metaplot metapost metauml mfpic mfpic4ode mp3d mpattern piechartmp roex slideshow splines textpath bin-metapost collection-metapost
"
TEXLIVE_MODULE_DOC_CONTENTS="automata.doc bbcard.doc blockdraw_mp.doc bpolynomial.doc cmarrows.doc dviincl.doc emp.doc epsincl.doc expressg.doc exteps.doc featpost.doc hatching.doc latexmp.doc metaobj.doc metaplot.doc metapost.doc metauml.doc mfpic.doc mfpic4ode.doc mp3d.doc mpattern.doc piechartmp.doc slideshow.doc splines.doc textpath.doc bin-metapost.doc "
TEXLIVE_MODULE_SRC_CONTENTS="emp.source expressg.source mfpic.source mfpic4ode.source roex.source splines.source "
inherit texlive-module
DESCRIPTION="TeXLive MetaPost (and Metafont) drawing packages"

LICENSE="GPL-2 as-is freedist GPL-1 LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2008
"
RDEPEND="${DEPEND}"
