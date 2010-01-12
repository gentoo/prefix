# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-metapost/texlive-metapost-2009.ebuild,v 1.1 2010/01/11 03:32:05 aballier Exp $

TEXLIVE_MODULE_CONTENTS="automata bbcard blockdraw_mp bpolynomial cmarrows drv dviincl emp epsincl expressg exteps featpost garrigues hatching latexmp metago metaobj metaplot metapost metauml mfpic mfpic4ode mp3d mpattern piechartmp roex slideshow splines suanpan textpath collection-metapost
"
TEXLIVE_MODULE_DOC_CONTENTS="automata.doc bbcard.doc blockdraw_mp.doc bpolynomial.doc cmarrows.doc drv.doc dviincl.doc emp.doc epsincl.doc expressg.doc exteps.doc featpost.doc garrigues.doc hatching.doc latexmp.doc metago.doc metaobj.doc metaplot.doc metapost.doc metauml.doc mfpic.doc mfpic4ode.doc mp3d.doc mpattern.doc piechartmp.doc slideshow.doc splines.doc suanpan.doc textpath.doc "
TEXLIVE_MODULE_SRC_CONTENTS="emp.source expressg.source mfpic.source mfpic4ode.source roex.source splines.source "
inherit texlive-module
DESCRIPTION="TeXLive MetaPost (and Metafont) drawing packages"

LICENSE="GPL-2 as-is freedist GPL-1 LGPL-2 LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
"
RDEPEND="${DEPEND} "

# This small hack is needed in order to have a sane upgrade path:
# the new TeX Live 2009 metapost produces this file but it is not recorded in
# any package; when running fmtutil (like texmf-update does) this file will be
# created and cause collisions.

pkg_setup() {
	if [ -f "${EROOT}/var/lib/texmf/web2c/metapost/mplib-luatex.mem" ]; then
		einfo "Removing ${EROOT}/var/lib/texmf/web2c/metapost/mplib-luatex.mem"
		rm -f "${EROOT}/var/lib/texmf/web2c/metapost/mplib-luatex.mem"
	fi
}
